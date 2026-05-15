extends Node

# USAGE ---
# This order will spend some time tracking the target at some accuracy rate, then launch a fast projectile at them
# The pursuit target should be set during the controlled body's on_ready action, otherwise it will default to the player_ship
# ARE YOU REUISNG THIS ORDER FOR A NEW CHARACTER? Great! That's intended, configure it in the -editor- using the export vars.
# --- If you change this code, you change the instructions for ALL CHARACTERS that use this order type

@export var min_offset: float = 250
@export var max_offset: float = 400
@export var projectile_speed: float = 1200
@export var tracking_speed: float = 450

var controller: Node
var character: CharacterBody2D = null
var target = null
var order_data = {}

const ORDER_DURATION: float = 1.9
var execution_time: float = 0
var just_started: bool = true

const SHOOT_TIMER: float = 1.8
var shoot_time: float = 1.8

const TARGET_INDICATOR = preload("uid://dsbyr6xn56eg4")
const TARGET_LINE = preload("uid://c68eu6qksr8n5")
const SHOOT_LINE = preload("uid://7b8ahfruxcgl")

const TARGET_INDICATOR_ART = preload("uid://cqe8li46sh7w2")
const TARGET_LINE_ART = preload("uid://b2k88n4s7ghoj")
const SHOOT_LINE_ART = preload("uid://be3j5g2ioln0t")

const ENEMY_LASER = preload("uid://8x3hw3dhpryy")
const ENEMY_LASER_ART = preload("res://Assets/Textures/cyber_shot.png")

const FIRST_INDICATOR_DISTANCE: float = 100


func _ready() -> void:
	if target == null: target = Global.level.player_ship

# Plot an instance of this order, saved to the controller's current order_id
func plot_order() -> void:
	var order_id = controller.plotting_order_id
	
	# Find where we're trying to shoot
	var order_origin = controller.get_order_finish(order_id - 1)
	var order_finish = order_origin
	var order_target = target.global_position + (Vector2(randf_range(-1, 1), randf_range(-1, 1)) * randf_range(min_offset, max_offset))
	var shoot_dir = (order_target - character.global_position).normalized()
	var first_indicator_pos = order_origin + (shoot_dir * FIRST_INDICATOR_DISTANCE)
	var tracked_pos = order_target
	
	
	# Create an indicator for where we're going
	var order_indicator = TARGET_INDICATOR.instantiate()
	order_indicator.label = ""
	order_indicator.position = first_indicator_pos
	character.add_sibling(order_indicator)
	order_indicator.sprite.texture = TARGET_INDICATOR_ART
	
	# Create a line for where we're going
	var order_line = TARGET_LINE.instantiate()
	order_line.set_point_position(0, order_origin)
	order_line.set_point_position(1, first_indicator_pos)
	character.add_sibling(order_line)
	order_line.texture = TARGET_LINE_ART
	
	# Create a shootline for our projectile
	var shoot_line = SHOOT_LINE.instantiate()
	shoot_line.set_point_position(0, first_indicator_pos)
	shoot_line.set_point_position(1, order_origin + (shoot_dir * projectile_speed * (4 - (SHOOT_TIMER + order_id))))
	character.add_sibling(shoot_line)
	shoot_line.texture = SHOOT_LINE_ART
	
	# Create a tracking indicator for this snipe
	var tracking_indicator = TARGET_INDICATOR.instantiate()
	tracking_indicator.label = ""
	tracking_indicator.position = tracked_pos
	character.add_sibling(tracking_indicator)
	tracking_indicator.sprite.texture = TARGET_INDICATOR_ART
	
	# Save data we need for executing this order
	order_data[order_id] = {
		"origin": order_origin,
		"finish": order_finish,
		"tracked_pos": tracked_pos,
		"indicator": order_indicator,
		"line": order_line,
		"shoot_line": shoot_line,
		"tracking_indicator": tracking_indicator,
	}

# Executes one physics frame of this order type, based on the contollers current order_id, returns true if the order is complete.+
func execute_order(delta: float) -> bool:
	# If we just entered this order, start our timer for leaving
	if just_started == true:
		just_started = false
		execution_time = ORDER_DURATION
		shoot_time = SHOOT_TIMER
	
	# Move the tracker towards the target's current position
	var order_id = controller.executing_order_id
	var order_origin = order_data[order_id]["origin"]
	var tracked_pos = order_data[order_id]["tracked_pos"]
	var indicator = order_data[order_id]["indicator"]
	var line = order_data[order_id]["line"]
	var shoot_line = order_data[order_id]["shoot_line"]
	var tracking_indicator = order_data[order_id]["tracking_indicator"]
	var desired_target = target.global_position
	print("Tracked position: ", tracked_pos)
	tracked_pos = tracked_pos.move_toward(desired_target, tracking_speed * delta)
	print("Updated to: ", tracked_pos)
	var shoot_dir = (tracked_pos - order_origin).normalized()
	if order_origin.distance_to(tracked_pos) > (projectile_speed * (4 - (SHOOT_TIMER + order_id))):
		tracked_pos = order_origin + (shoot_dir * projectile_speed * (4 - (SHOOT_TIMER + order_id)))
	order_data[order_id]["tracked_pos"] = tracked_pos
	
	# Update the visuals
	character.sprite.rotation = lerp_angle(character.sprite.rotation, shoot_dir.angle(), 0.5)
	var first_indicator_pos = order_origin + (shoot_dir * FIRST_INDICATOR_DISTANCE)
	line.set_point_position(1, first_indicator_pos)
	indicator.position = first_indicator_pos
	shoot_line.set_point_position(0, first_indicator_pos)
	shoot_line.set_point_position(1, order_origin + (shoot_dir * projectile_speed * (4 - (SHOOT_TIMER + order_id))))
	tracking_indicator.position = tracked_pos
	
	# Check if it's now time to fire a shot
	shoot_time -= delta
	if shoot_time <= 0:
		shoot_time += SHOOT_TIMER
		var true_origin = character.global_position
		shoot_dir = (tracked_pos - order_origin).normalized()
		var new_laser = Global.create_interactable(ENEMY_LASER, true_origin + (FIRST_INDICATOR_DISTANCE * shoot_dir), true_origin + (10000 * shoot_dir), projectile_speed)
		Global.level.add_child(new_laser)
		new_laser.sprite.texture = ENEMY_LASER_ART
		
	# Check if this order is now finished
	execution_time -= delta
	if execution_time <= 0:
		order_data[order_id]["indicator"].hide()
		order_data[order_id]["line"].hide()
		order_data[order_id]["shoot_line"].hide()
		order_data[order_id]["tracking_indicator"].hide()
		just_started = true
		return true
		
	return false

# Clean up this order's indicators and tidy up anything else it needs to
func clear_orders() -> void:
	for key in order_data:
		order_data[key]["indicator"].queue_free()
		order_data[key]["line"].queue_free()
		order_data[key]["shoot_line"].queue_free()
		order_data[key]["tracking_indicator"].queue_free()
	order_data.clear()
	just_started = true
	shoot_time = SHOOT_TIMER
	
# Sets the alpha of the displayed orders
func set_alpha(alpha: float) -> void:
	for key in order_data:
		order_data[key]["indicator"].modulate = Color(1, 1, 1, alpha/255)
		order_data[key]["line"].modulate = Color(1, 1, 1, alpha/255)
		order_data[key]["shoot_line"].modulate = Color(1, 1, 1, alpha/255)
		order_data[key]["tracking_indicator"].modulate = Color(1, 1, 1, alpha/255)

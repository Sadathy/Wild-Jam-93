extends Node

# USAGE ---
# This order will spend some amount of time moving at some speed roughly towards the location of the pursuit target
# The pursuit target should be set during the controlled body's on_ready action, otherwise it will default to the player_ship
# ARE YOU REUISNG THIS ORDER FOR A NEW CHARACTER? Great! That's intended, configure it in the -editor- using the export vars.
# --- If you change this code, you change the instructions for ALL CHARACTERS that use this order type

@export var min_offset: float = 20
@export var max_offset: float = 320
@export var projectile_speed: float = 900

var controller: Node
var character: CharacterBody2D = null
var target = null
var order_data = {}

const ORDER_DURATION: float = 0.95
var execution_time: float = 0
var just_started: bool = true

const SHOOT_TIMER: float = 1.0
var shoot_time: float = 0

const TARGET_INDICATOR = preload("uid://dsbyr6xn56eg4")
const TARGET_LINE = preload("uid://c68eu6qksr8n5")
const SHOOT_LINE = preload("uid://7b8ahfruxcgl")

const TARGET_INDICATOR_ART = preload("uid://cqe8li46sh7w2")
const TARGET_LINE_ART = preload("uid://b2k88n4s7ghoj")
const SHOOT_LINE_ART = preload("uid://be3j5g2ioln0t")

const ENEMY_LASER = preload("uid://8x3hw3dhpryy")


func _ready() -> void:
	if target == null: target = Global.level.player_ship

# Plot an instance of this order, saved to the controller's current order_id
func plot_order() -> void:
	var order_id = controller.plotting_order_id
	
	# Find where we're trying to shoot
	var order_origin = controller.get_order_finish(order_id - 1)
	var order_finish = order_origin
	var order_target = target.global_position + (Vector2.from_angle(randf() * 2 * PI) * randf_range(min_offset, max_offset))
	var shoot_dir = (order_target - character.global_position).normalized()
	var indicator_start_pos = (shoot_dir * 100) + order_origin
	var indicator_finish_pos = (shoot_dir * (((projectile_speed * ORDER_DURATION * (4 - (order_id * ORDER_DURATION))) + 100))) + order_origin
	
	# Create an indicator for where we're going
	var order_indicator = TARGET_INDICATOR.instantiate()
	order_indicator.label = ""
	order_indicator.position = indicator_start_pos
	character.add_sibling(order_indicator)
	order_indicator.sprite.texture = TARGET_INDICATOR_ART
	
	# Create a line for where we're going
	var order_line = TARGET_LINE.instantiate()
	order_line.set_point_position(0, order_origin)
	order_line.set_point_position(1, indicator_start_pos)
	character.add_sibling(order_line)
	order_line.texture = TARGET_LINE_ART
	
	# Create a shootline for our projectile
	var shoot_line = SHOOT_LINE.instantiate()
	shoot_line.set_point_position(0, indicator_start_pos)
	shoot_line.set_point_position(1, indicator_finish_pos)
	character.add_sibling(shoot_line)
	shoot_line.texture = SHOOT_LINE_ART
	
	# Save data we need for executing this order
	order_data[order_id] = {
		"origin": order_origin,
		"finish": order_finish,
		"indicator": order_indicator,
		"line": order_line,
		"shoot_line": shoot_line,
		"shoot_dir": shoot_dir,
	}

# Executes one physics frame of this order type, based on the contollers current order_id, returns true if the order is complete.+
func execute_order(delta: float) -> bool:
	# If we just entered this order, start our timer for leaving
	if just_started == true:
		just_started = false
		execution_time = ORDER_DURATION
	
	# Move face towards the target point
	var order_id = controller.executing_order_id
	var shoot_dir = order_data[order_id]["shoot_dir"]
	
	character.sprite.rotation = lerp_angle(character.sprite.rotation, shoot_dir.angle(), 0.5)
	
	# Check if it's now time to fire a shot
	shoot_time -= delta
	if shoot_time <= 0:
		shoot_time += SHOOT_TIMER
		var true_origin = character.global_position
		var new_laser = Global.create_interactable(ENEMY_LASER, true_origin + (100 * shoot_dir), true_origin + (10000 * shoot_dir), projectile_speed)
		Global.level.add_child(new_laser)
		
	# Check if this order is now finished
	execution_time -= delta
	if execution_time <= 0:
		order_data[order_id]["indicator"].hide()
		order_data[order_id]["line"].hide()
		order_data[order_id]["shoot_line"].hide()
		just_started = true
		return true
		
	return false

# Clean up this order's indicators and tidy up anything else it needs to
func clear_orders() -> void:
	for key in order_data:
		order_data[key]["indicator"].queue_free()
		order_data[key]["line"].queue_free()
		order_data[key]["shoot_line"].queue_free()
	order_data.clear()
	just_started = true
	shoot_time = 0

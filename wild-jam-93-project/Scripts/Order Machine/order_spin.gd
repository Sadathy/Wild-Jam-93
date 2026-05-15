extends Node

# USAGE ---
# This order will make the controller character wildly spin whilst careening through it's target
# The pursuit target should be set during the controlled body's on_ready action, otherwise it will default to the player_ship
# ARE YOU REUISNG THIS ORDER FOR A NEW CHARACTER? Great! That's intended, configure it in the -editor- using the export vars.
# --- If you change this code, you change the instructions for ALL CHARACTERS that use this order type

@export var min_offset: float = 40
@export var max_offset: float = 200
@export var speed: float = 400
@export var spin_rate: float = 6*PI

var controller: Node
var character: CharacterBody2D = null
var target = null
var order_data = {}

const ORDER_DURATION: float = 0.95
var execution_time: float = 0
var just_started: bool = true

const TARGET_INDICATOR = preload("uid://dsbyr6xn56eg4")
const TARGET_LINE = preload("uid://c68eu6qksr8n5")
const SHOOT_LINE = preload("uid://7b8ahfruxcgl")

const TARGET_INDICATOR_ART = preload("res://Assets/Textures/target_indicator_enemy.png")
const TARGET_LINE_ART = preload("res://Assets/Textures/target_line_enemy.png")
const SHOOT_LINE_ART = preload("uid://be3j5g2ioln0t")


func _ready() -> void:
	if target == null: target = Global.level.player_ship

# Plot an instance of this order, saved to the controller's current order_id
func plot_order() -> void:
	var order_id = controller.plotting_order_id
	
	# Find where we're actually going
	var order_origin = controller.get_order_finish(order_id - 1)
	var order_target = target.position + (Vector2.from_angle(randf() * 2 * PI) * randf_range(min_offset, max_offset))
	var order_finish = ((order_target - order_origin).normalized() * speed * ORDER_DURATION) + order_origin
	var spin_angle = (target.position - order_origin).angle()
	
	# Create an indicator for where we're going
	var order_indicator = TARGET_INDICATOR.instantiate()
	order_indicator.label = ""
	order_indicator.position = order_finish
	character.add_sibling(order_indicator)
	order_indicator.sprite.texture = TARGET_INDICATOR_ART
	
	# Create a line for where we're going
	var order_line = TARGET_LINE.instantiate()
	order_line.set_point_position(0, order_origin)
	order_line.set_point_position(1, order_finish)
	character.add_sibling(order_line)
	order_line.texture = TARGET_LINE_ART
	
	# Create a shoot line so the player knows this is dangerous!
	var shoot_line = SHOOT_LINE.instantiate()
	shoot_line.set_point_position(0, order_origin)
	shoot_line.set_point_position(1, order_finish)
	character.add_sibling(shoot_line)
	shoot_line.texture = SHOOT_LINE_ART
	shoot_line.width = 163
	
	# Save data we need for executing this order
	order_data[order_id] = {
		"origin": order_origin,
		"finish": order_finish,
		"indicator": order_indicator,
		"line": order_line,
		"shoot_line": shoot_line,
		"angle": spin_angle
	}

# Executes one physics frame of this order type, based on the contollers current order_id, returns true if the order is complete.+
func execute_order(delta: float) -> bool:
	# If we just entered this order, start our timer for leaving
	if just_started == true:
		just_started = false
		execution_time = ORDER_DURATION
	
	# Move and face towards the finish point
	var order_id = controller.executing_order_id
	var order_finish = order_data[order_id]["finish"]
	
	# Make us spin!!!!
	var spin_angle = order_data[order_id]["angle"]
	spin_angle += spin_rate * delta
	character.sprite.rotation = spin_angle
	order_data[order_id]["angle"] = spin_angle
	
	character.position = character.position.move_toward(order_finish, speed * delta)
	
	# Update the position of the order line
	order_data[order_id]["line"].set_point_position(0, character.position)
	
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

# Sets the alpha of the displayed orders
func set_alpha(alpha: float) -> void:
	for key in order_data:
		order_data[key]["indicator"].modulate = Color(1, 1, 1, alpha/255)
		order_data[key]["line"].modulate = Color(1, 1, 1, alpha/255)
		order_data[key]["shoot_line"].modulate = Color(1, 1, 1, alpha/255)

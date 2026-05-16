extends Node

# USAGE ---
# This order will cause the character to strafe perpendicular to its target's position
# The strafe target should be set during the controlled body's on_ready action, otherwise it will default to the player_ship
# ARE YOU REUISNG THIS ORDER FOR A NEW CHARACTER? Great! That's intended, configure it in the -editor- using the export vars.
# --- If you change this code, you change the instructions for ALL CHARACTERS that use this order type

@export var speed: float = 200

var controller: Node
var character: CharacterBody2D = null
var target = null
var order_data = {}

const ORDER_DURATION: float = 0.95
var execution_time: float = 0
var just_started: bool = true

const TARGET_INDICATOR = preload("uid://dsbyr6xn56eg4")
const TARGET_LINE = preload("uid://c68eu6qksr8n5")

const TARGET_INDICATOR_ART = preload("res://Assets/Textures/target_indicator_move.png")
const TARGET_LINE_ART = preload("res://Assets/Textures/target_line_move.png")


func _ready() -> void:
	if target == null: target = Global.level.player_ship

# Plot an instance of this order, saved to the controller's current order_id
func plot_order() -> void:
	var order_id = controller.plotting_order_id
	
	# Find where we're actually going
	var order_origin = controller.get_order_finish(order_id - 1)
	var strafe_angle = order_origin.angle_to_point(target.position) + (0.5*PI)
	var order_finish = (Vector2.from_angle(strafe_angle) * speed * ORDER_DURATION) + order_origin
	
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
	
	# Save data we need for executing this order
	order_data[order_id] = {
		"origin": order_origin,
		"finish": order_finish,
		"indicator": order_indicator,
		"line": order_line
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
	
	character.sprite.rotation = lerp_angle(character.sprite.rotation, character.position.angle_to_point(target.position), 3 * PI * delta)
	
	character.position = character.position.move_toward(order_finish, speed * delta)
	
	# Update the position of the order line
	order_data[order_id]["line"].set_point_position(0, character.position)
	
	# Check if this order is now finished
	execution_time -= delta
	if execution_time <= 0:
		order_data[order_id]["indicator"].hide()
		order_data[order_id]["line"].hide()
		just_started = true
		return true
		
	return false

# Clean up this order's indicators and tidy up anything else it needs to
func clear_orders() -> void:
	for key in order_data:
		order_data[key]["indicator"].queue_free()
		order_data[key]["line"].queue_free()
	order_data.clear()
	just_started = true

# Sets the alpha of the displayed orders
func set_alpha(alpha: float) -> void:
	for key in order_data:
		order_data[key]["indicator"].modulate = Color(1, 1, 1, alpha/255)
		order_data[key]["line"].modulate = Color(1, 1, 1, alpha/255)

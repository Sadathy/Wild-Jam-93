extends Node

# USAGE ---
# This order will cause the character to hold it's position whilst tracking the target's position with it's facing
# The  target should be set during the controlled body's on_ready action, otherwise it will default to the player_ship
# ARE YOU REUISNG THIS ORDER FOR A NEW CHARACTER? Great! That's intended, configure it in the -editor- using the export vars.
# --- If you change this code, you change the instructions for ALL CHARACTERS that use this order type

var controller: Node
var controller_parent: Node
var character: CharacterBody2D = null
var target = null
var order_data = {}

const ORDER_DURATION: float = 0.95
var execution_time: float = 0
var just_started: bool = true

func _ready() -> void:
	if target == null: target = Global.level.player_ship

# Plot an instance of this order, saved to the controller's current order_id
func plot_order() -> void:
	var order_id = controller.plotting_order_id
	
	# Find where we're trying to shoot
	var order_origin = controller.get_order_finish(order_id - 1)
	var order_finish = order_origin

	# Save data we need for executing this order
	order_data[order_id] = {
		"origin": order_origin,
		"finish": order_finish
	}

# Executes one physics frame of this order type, based on the contollers current order_id, returns true if the order is complete.+
func execute_order(delta: float) -> bool:
	# If we just entered this order, start our timer for leaving
	if just_started == true:
		just_started = false
		execution_time = ORDER_DURATION
	
	# Move face towards the target point
	var order_id = controller.executing_order_id
	
	character.sprite.rotation = lerp_angle(character.sprite.rotation, character.global_position.angle_to_point(target.global_position), 0.3)
		
	# Check if this order is now finished
	execution_time -= delta
	if execution_time <= 0:
		just_started = true
		return true
		
	return false

# Clean up this order's indicators and tidy up anything else it needs to
func clear_orders() -> void:
	order_data.clear()
	just_started = true
	
# Sets the alpha of the displayed orders
func set_alpha(alpha: float) -> void:
	return

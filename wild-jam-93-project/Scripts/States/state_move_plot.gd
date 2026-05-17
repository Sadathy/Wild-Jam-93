extends State

@onready var player_ship: CharacterBody2D = $"../../.."

var indicator = null
var line = null
var fuel_on_enter: float = 0
var order: Dictionary = {}
var order_origin: Vector2 = Vector2.ZERO

const TARGET_INDICATOR = preload("uid://dsbyr6xn56eg4")
const TARGET_LINE = preload("uid://c68eu6qksr8n5")

@onready var tutorial_manager: Node = %TutorialManager

func on_enter(_entry_data: Dictionary = {}) -> void:
	# Set up interface
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	CONTROLLER.button_cancel.disabled = false
	CONTROLLER.button_cancel.show()
	CONTROLLER.button_move.disabled = true
	CONTROLLER.button_move.hide()
	CONTROLLER.button_attack.disabled = true
	CONTROLLER.button_attack.hide()
	CONTROLLER.label_orders.text = "Moving"
	
	# Create order indicators
	indicator = TARGET_INDICATOR.instantiate()
	Global.level.add_child(indicator)
	indicator.modulate = Color(1, 1, 1, 1)
	
	line = TARGET_LINE.instantiate()
	Global.level.add_child(line)
	line.modulate = Color(1, 1, 1, 1)
	
	# Initialise data for this order
	fuel_on_enter = player_ship.fuel
	if CONTROLLER.order_id > 1:
		order_origin = CONTROLLER.plotted_orders[CONTROLLER.order_id - 1]["target"]
	else:
		order_origin = player_ship.position
	
	order = {}
	

func on_exit() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if order == {}: player_ship.fuel = fuel_on_enter
	indicator.queue_free()
	line.queue_free()

func on_process(_delta) -> void:
	if Input.is_action_just_pressed("plot_cancel"):
		CONTROLLER.on_press_cancel()
		return

	var mouse_pos = get_global_mouse_position()

	
	# Set the fuel level to the current proposed distance
	player_ship.fuel = fuel_on_enter - order_origin.distance_to(mouse_pos)
	
	# If we'll be out of fuel, snap the mouse back and snap fuel to 0
	if player_ship.fuel < 0:
		player_ship.fuel = 0
		var new_mouse_pos = ((mouse_pos - order_origin).normalized() * fuel_on_enter) + order_origin
		mouse_pos = new_mouse_pos
	
	# If we're below our minimum fuel spend, snap the mouse out to minimum
	if (fuel_on_enter - CONTROLLER.MIN_PLOT_FUEL) < player_ship.fuel:
		player_ship.fuel = fuel_on_enter - CONTROLLER.MIN_PLOT_FUEL
		var new_mouse_pos = ((mouse_pos - order_origin).normalized() * CONTROLLER.MIN_PLOT_FUEL) + order_origin
		mouse_pos = new_mouse_pos
		
	indicator.position = mouse_pos
	line.set_point_position(0, order_origin)
	line.set_point_position(1, mouse_pos)
	
	# Handle us plotting the point
	if Input.is_action_just_pressed("plot"):
		var new_indicator = TARGET_INDICATOR.instantiate()
		new_indicator.position = mouse_pos
		new_indicator.label = str(CONTROLLER.order_id)
		Global.level.add_child(new_indicator)
		new_indicator.modulate = Color(1, 1, 1, 1)
		var new_line = TARGET_LINE.instantiate()
		new_line.set_point_position(0, order_origin)
		new_line.set_point_position(1, mouse_pos)
		Global.level.add_child(new_line)
		new_line.modulate = Color(1, 1, 1, 1)
		order = {
			"origin": order_origin,
			"target": mouse_pos,
			"order_string": "move",
			"order_id": CONTROLLER.order_id,
			"indicator": new_indicator,
			"line": new_line,
			"fuel_cost": fuel_on_enter - player_ship.fuel
		}
		CONTROLLER.plotted_orders[CONTROLLER.order_id] = order
		CONTROLLER.order_id += 1
		CONTROLLER.change_state(CONTROLLER.STATE_NO_PLOT)
		if tutorial_manager.in_tutorial == true and tutorial_manager.tutorial_step == 2:
			Global.level.tutorial_step += 1
		
	

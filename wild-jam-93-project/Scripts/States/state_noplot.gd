extends State

@onready var camera: Camera2D = %Camera
@onready var player_ship: CharacterBody2D = $"../../.."

const TIME_BAR_UNDER_OOF = preload("uid://b45e6foxnfm75")
@onready var tutorial_manager: Node = %TutorialManager


func on_enter(_entry_data: Dictionary = {}) -> void:
	CONTROLLER.button_cancel.disabled = true
	CONTROLLER.button_cancel.hide()
	CONTROLLER.button_move.disabled = false
	CONTROLLER.button_move.show()
	CONTROLLER.button_attack.disabled = false
	CONTROLLER.button_attack.show()
	CONTROLLER.button_undo.disabled = false
	CONTROLLER.button_undo.show()
	CONTROLLER.label_orders.text = "Orders"
	player_ship.button_end_turn.disabled = false
	
	# If we don't have enough fuel to take another action, we should show that!
	if CONTROLLER.player_ship.fuel < CONTROLLER.MIN_PLOT_FUEL:
		CONTROLLER.button_move.disabled = true
		CONTROLLER.button_attack.disabled = true
		CONTROLLER.bar_fuel.texture_under = TIME_BAR_UNDER_OOF
		
	# If we have an order, tell the camera to move to the last order's target
	if CONTROLLER.order_id != 1:
		camera.desired_position = (CONTROLLER.plotted_orders[CONTROLLER.order_id - 1]["target"] - player_ship.position)
	else:
		camera.desired_position = Vector2.ZERO
		
	
func on_exit() -> void:
	CONTROLLER.button_undo.disabled = true
	CONTROLLER.button_undo.hide()
	
func on_process(_delta) -> void:
	if Input.is_action_just_pressed("plot_attack"):
		if tutorial_manager.in_tutorial == false:
			CONTROLLER.on_press_attack()
			return
		if tutorial_manager.tutorial_step < 10:
			return
		CONTROLLER.on_press_attack()
	if Input.is_action_just_pressed("plot_move"):
		if tutorial_manager.in_tutorial == false:
			CONTROLLER.on_press_move()
			return
		if tutorial_manager.tutorial_step < 2:
			return
		CONTROLLER.on_press_move()
		return
	if Input.is_action_just_pressed("plot_undo"):
		CONTROLLER.on_press_undo()
		return

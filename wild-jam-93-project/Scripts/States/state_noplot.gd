extends State

const TIME_BAR_UNDER_OOF = preload("uid://b45e6foxnfm75")


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
	
	# If we don't have enough fuel to take another action, we should show that!
	if CONTROLLER.player_ship.fuel < CONTROLLER.MIN_PLOT_FUEL:
		CONTROLLER.button_move.disabled = true
		CONTROLLER.button_attack.disabled = true
		CONTROLLER.bar_fuel.texture_under = TIME_BAR_UNDER_OOF
		
	
func on_exit() -> void:
	CONTROLLER.button_undo.disabled = true
	CONTROLLER.button_undo.hide()
	
func on_process(_delta) -> void:
	if Input.is_action_just_pressed("plot_attack"):
		CONTROLLER.on_press_attack()
		return
	if Input.is_action_just_pressed("plot_move"):
		CONTROLLER.on_press_move()
		return
	if Input.is_action_just_pressed("plot_undo"):
		CONTROLLER.on_press_undo()
		return

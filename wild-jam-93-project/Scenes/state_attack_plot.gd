extends State

func on_enter(_entry_data: Dictionary = {}) -> void:
	CONTROLLER.button_cancel.disabled = false
	CONTROLLER.button_cancel.show()
	CONTROLLER.button_move.disabled = true
	CONTROLLER.button_move.hide()
	CONTROLLER.button_attack.disabled = true
	CONTROLLER.button_attack.hide()
	CONTROLLER.label_orders.text = "Attacking"

func on_process(_delta) -> void:
	if Input.is_action_just_pressed("plot_cancel"):
		CONTROLLER.on_press_cancel()
		return

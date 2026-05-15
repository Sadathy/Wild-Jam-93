extends Label

const CHANGE_RATE: int = 1

var target_value: int = 0

func _process(_delta: float) -> void:
	if target_value == Global.credits: return
	if target_value < Global.credits:target_value += CHANGE_RATE
	if target_value > Global.credits: target_value = Global.credits
	text = "Spice: " + str(target_value)

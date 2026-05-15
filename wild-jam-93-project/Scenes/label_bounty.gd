extends Label

const CHANGE_RATE: int = 1

var target_value: int = 0

func _process(_delta: float) -> void:
	if target_value == Global.bounty: return
	if target_value < Global.bounty: target_value += CHANGE_RATE
	if target_value > Global.bounty: target_value = Global.bounty
	text = "Bounty: $" + str(target_value)

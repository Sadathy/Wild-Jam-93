extends Area2D

var level: Node

signal player_tried_exit

func _ready() -> void:
	level = get_parent()
	body_entered.connect(on_ship_enter)
	
func on_ship_enter(entering_body) -> void:
	if entering_body != level.player_ship:
		return
	print("Player ship entered the gateway")
	player_tried_exit.emit()
	

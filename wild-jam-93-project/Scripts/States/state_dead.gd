extends State

@onready var player_ship: CharacterBody2D = $"../../.."
@onready var menu_game: PanelContainer = %MenuGame


func on_enter(_entry_data: Dictionary = {}) -> void:
	menu_game.show()
	player_ship.sprite.hide()
	Global.turn_timer -= Global.DEFAULT_TURN_DURATION

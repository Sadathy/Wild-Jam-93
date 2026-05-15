extends Label

@onready var player_ship: CharacterBody2D = $"../../../../../.."

func _process(_delta: float) -> void:
	if player_ship.alive == true:
		return
	text = str("You scored ", str(Global.credits), " spice! Then you died...")

extends CanvasLayer

@onready var label_turn: Label = %LabelTurn

const SHIP = preload("res://Scenes/player_ship.tscn")
const DEFAULT_TURN_TEXT = "Your turn, press space to end"

var player_ship: Node2D = null

func _ready() -> void:
	player_ship = SHIP.instantiate()
	player_ship.position = Vector2(300, 300)
	add_child(player_ship)
	
	Global.turn_started.connect(see_turn_started)
		
func _process(_delta: float) -> void:
	if Global.player_turn == false:
		label_turn.text = "Time left: " + str(Global.turn_timer).pad_decimals(2)

func see_turn_started() -> void:
	label_turn.text = DEFAULT_TURN_TEXT
	
	

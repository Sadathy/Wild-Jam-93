extends Label

const DEFAULT_TURN_TEXT = "Your turn, press space to end"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.turn_ended.connect(on_turn_end)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.player_turn == false:
		text = "Time remaining: " + str(Global.turn_timer).pad_decimals(2)

func on_turn_end() -> void:
	text = "It's your turn, plot some actions then press space to end your turn."

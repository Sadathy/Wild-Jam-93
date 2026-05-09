extends Node

@export var volume: float = 50.0
@export var difficulty: float = 2.0
@export var DEFAULT_TURN_DURATION: float = 3.0

# Some signals so our code knows when new turns start/end
signal turn_ended
signal turn_started

# A var so we know whether it's the player's turn or not
var player_turn: bool = true
var turn_timer: float = 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("next_turn") and player_turn == true:
		player_turn = false
		turn_timer = DEFAULT_TURN_DURATION
		turn_ended.emit()
		return
		
	if player_turn == false:
		turn_timer -= delta
		if turn_timer <= 0:
			player_turn = true
			turn_started.emit()
		
		

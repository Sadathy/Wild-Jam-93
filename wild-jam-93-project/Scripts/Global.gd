extends Node

@export var volume: float = 50.0
@export var difficulty: float = 2.0
@export var DEFAULT_TURN_DURATION: float = 3.0

const LEVEL = preload("res://Scenes/level.tscn")

# Some signals so our code knows when new turns start/end
signal turn_ended
signal turn_started

# A var so we know whether it's the player's turn or not
var player_turn: bool = true
var turn_timer: float = 0.0
var turn_count = 0

# Keep track of what level we're on
var level: Node2D = null

# So we can show the main menue
var main_menu = null

func _process(delta: float) -> void:
	# Only do turn processing if we are in a level
	if level == null:
		return
	
	if Input.is_action_just_pressed("next_turn") and player_turn == true:
		AudioManager.play_looping(preload("res://Assets/Audio/engine_loop.ogg"), "engine")
		player_turn = false
		turn_timer = DEFAULT_TURN_DURATION
		turn_ended.emit()
		return
		
	if player_turn == false:
		turn_timer -= delta
		if turn_timer <= 0:
			AudioManager.stop_looping("engine")
			player_turn = true
			turn_count += 1
			turn_started.emit()

		
func create_interactable(new_object_type, new_origin: Vector2, new_target: Vector2, new_speed: float) -> Node2D:
	var new_object = new_object_type.instantiate()
	#new_object.position = new_origin
	new_object.origin_point = new_origin
	new_object.target_point = new_target
	new_object.speed = new_speed
	
	return new_object

func pressed_retry() -> void:
	level.queue_free()
	new_level()

func pressed_main_menu() -> void:
	level.queue_free()
	main_menu.show()

func new_level() -> void:
	var new_level_instance = LEVEL.instantiate()
	level = new_level_instance
	get_tree().get_root().add_child(new_level_instance)

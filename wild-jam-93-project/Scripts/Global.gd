extends Node

const SPICE = preload("res://Scenes/Interactables/spice.tscn")
const SPICEBLOW = preload("res://Scenes/Effects/spiceblow.tscn")

@export var difficulty: float = 2.0
@export var DEFAULT_TURN_DURATION: float = 3.0

const LEVEL_GENERIC = preload("res://Scenes/Levels/level.tscn")
const LEVEL_TUTORIAL = preload("res://Scenes/Levels/TutorialLevel.tscn")


# Some signals so our code knows when new turns start/end
signal turn_ended
signal turn_started

# A var so we know whether it's the player's turn or not
var player_turn: bool = true
var turn_timer: float = 0.0
var turn_count = 0
var paused = false

# Player progression
var bounty: int = 0
var credits: int = 0

# Keep track of what level we're on
var level: Node2D = null

# So we can show the main menue
var main_menu = null

# So we know what level we're on
var current_level_type = null

func _process(delta: float) -> void:
	# Only do turn processing if we are in a level and we are not paused
	if level == null or paused:
		return
	
	if Input.is_action_just_pressed("next_turn") and player_turn == true:
		if level.player_ship.tutorial_manager.in_tutorial == false:
			on_press_next_turn()
			return
		if level.player_ship.tutorial_manager.tutorial_step < 4:
			return
		if level.player_ship.tutorial_manager.tutorial_step == 4:
			level.tutorial_step += 1
		on_press_next_turn()
		
	if player_turn == false:
		turn_timer -= delta
		level.player_ship.bar_fuel.value = (turn_timer/DEFAULT_TURN_DURATION)*100
		if turn_timer <= 0:
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
	AudioManager.play(preload("res://Assets/Audio/obsydianx/confirm_style_2_003.wav"))
	credits = 0
	bounty = 0
	level.queue_free()
	new_level(current_level_type)

func pressed_main_menu() -> void:
	AudioManager.play(preload("res://Assets/Audio/obsydianx/back_style_2_001.wav"))
	AudioManager.stop_music()
	Global.main_menu.menu_music()
	credits = 0
	bounty = 0
	level.queue_free()
	current_level_type = null
	main_menu.show()

func new_level(level_type) -> void:
	var new_level_instance = level_type.instantiate()
	current_level_type = level_type
	level = new_level_instance
	get_tree().get_root().add_child(new_level_instance)
	
func on_press_pause() -> void:
	paused = !paused
	print("Paused: ", paused)
	
	if paused:
		AudioManager.pause_music()
	else:
		AudioManager.resume_music()

func on_press_next_turn() -> void:
	player_turn = false
	turn_timer = DEFAULT_TURN_DURATION
	level.player_ship.button_end_turn.disabled = true
	turn_ended.emit()
	
func spice_blow(count: int = 1, location: Vector2 = Vector2.ZERO) -> void:
	var new_spice_blow = SPICEBLOW.instantiate()
	new_spice_blow.position = location
	new_spice_blow.lifespan = randf_range(0.8, 1.2)
	level.add_child(new_spice_blow)
	for i in count:
		var new_speed = randf_range(25, 225)
		var new_origin = location
		var new_target = location + Vector2(randf_range(-1, 1), randf_range(-1, 1))
		new_target = ((new_target - new_origin).normalized() * 10000) + new_origin
		var new_spice = SPICE.instantiate()
		new_spice.origin_point = new_origin
		new_spice.target_point = new_target
		new_spice.speed = new_speed
		level.add_child(new_spice)
		new_spice.add_to_group("spice")
		new_spice.order_machine.plot_order("OrderDrift")
		new_spice.order_machine.plot_order("OrderDrift")
		new_spice.order_machine.plot_order("OrderDrift")

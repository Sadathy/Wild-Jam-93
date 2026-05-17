extends Node2D

@export var max_x = 4000
@export var min_x = -500
@export var max_y = 1000
@export var min_y = -1000

@export var navy_threat: int = 0 # Scales from 0 to 10
@export var alien_threat: int = 0 # Scales from 0 to 10
@export var cyber_threat: int = 0 # Scales from 0 to 10
@export var asteroid_threat: int = 0 # Scales from 0 to 10
@export var cargo_level: int = 0 # Scales from 0 to 10
@export var spice_level: int = 0 # Scales from 0 to 10

@export var max_enemies: int = 6 # Whatever you want > 0

@export var music: AudioManager.Music = AudioManager.Music.NOVA

@onready var background: Polygon2D = %Background
@onready var exit_gate: Area2D = %ExitGate

@onready var leave_menu: PanelContainer = %LeaveMenu
@onready var button_leave_level: Button = %ButtonLeaveLevel
@onready var button_keep_playing: Button = %ButtonKeepPlaying

const SHIP = preload("res://Scenes/player_ship.tscn")
const ASTEROID = preload("res://Scenes/Interactables/asteroid.tscn")
const ENEMY_SHIP = preload("res://Scenes/Interactables/enemy_ship.tscn")
const FREIGHTER = preload("res://Scenes/Interactables/enemy_freighter.tscn")
const SPINNER = preload("res://Scenes/Interactables/spinner.tscn")
const SNIPER = preload("res://Scenes/Interactables/cyber_sniper.tscn")
const SPICE = preload("res://Scenes/Interactables/spice.tscn")
const CARGO = preload("res://Scenes/Interactables/civilian_ship.tscn")

var player_ship: Node2D = null

var considering_exit: bool = false

signal level_complete

func _ready() -> void:
	player_ship = SHIP.instantiate()
	player_ship.position = Vector2.ZERO 
	add_child(player_ship)
	
	player_ship.camera.limit_left = min_x
	player_ship.camera.limit_right = max_x
	player_ship.camera.limit_top = min_y
	player_ship.camera.limit_bottom = max_y
	
	var p_tl = Vector2(min_x, max_y)
	var p_tr = Vector2(max_x, max_y)
	var p_br = Vector2(max_x, min_y)
	var p_bl = Vector2(min_x, min_y)
	
	var p_arr = PackedVector2Array([p_tl, p_tr, p_br, p_bl])
	
	background.polygon = p_arr
	
	exit_gate.position.x = max_x - 200
	
	AudioManager.play_music(music)
	
	#SIGNALS
	Global.turn_started.connect(on_new_turn)
	exit_gate.player_tried_exit.connect(on_player_exit)
	player_ship.pause.connect(on_press_pause)
	button_leave_level.pressed.connect(on_press_leave_level)
	button_keep_playing.pressed.connect(on_press_keep_playing)
	
	Global.paused = false
	
	on_new_turn()

func on_player_exit() -> void:
	AudioManager.stop_all_looping()
	considering_exit = true
	leave_menu.show()
	player_ship.menu_pause.hide()
	Global.paused = true
	
func on_press_leave_level() -> void:
	Global.main_menu.menu_music()
	level_complete.emit()
	Global.level = null
	queue_free()
	
func on_press_keep_playing() -> void:
	considering_exit = false
	leave_menu.hide()
	Global.paused = false

func on_new_turn() -> void:
	# Find the basic enemy type of this stage, if there are no enemies then add one
	var enemy_count = get_tree().get_nodes_in_group("enemies").size()
	var primary_enemy = "navy"
	if alien_threat > navy_threat: primary_enemy = "alien"
	if cyber_threat > alien_threat and cyber_threat > alien_threat: primary_enemy = "cyber"
	if enemy_count <= 0 and max_enemies > 0:
		if primary_enemy == "navy":
			spawn_enemy(ENEMY_SHIP)
			enemy_count += 1
		if primary_enemy == "alien":
			spawn_enemy(SPINNER)
			enemy_count += 1
		if primary_enemy == "cyber":
			spawn_enemy(SNIPER)
			enemy_count += 1
	# If we are below our max enemy count, go through and potentially spawn more enemies
	if enemy_count < max_enemies + (2 * int(Global.difficulty)) and max_enemies > 0:
		# Check threat thresholds for current bounty
		var threat_threshold = Global.get_threat_threshold()
		# If our threat threshold is below the threat level on this map, have a chance to spawn an enemy
		# The navy starts spawning freighters if threat differential exceeds 6
		if threat_threshold + 5 < navy_threat and enemy_count < max_enemies + (2 * int(Global.difficulty)):
			# 10% chance for a ship per threat above threshold
			if randi_range(1, 10) <= navy_threat - (threat_threshold + 5):
				spawn_enemy(FREIGHTER)
				enemy_count += 1
		if threat_threshold < navy_threat and enemy_count < max_enemies + (2 * int(Global.difficulty)):
			# 10% chance for a ship per threat above threshold
			if randi_range(1, 10) <= navy_threat - threat_threshold:
				spawn_enemy(ENEMY_SHIP)
				enemy_count += 1
		if threat_threshold < alien_threat and enemy_count < max_enemies + (2 * int(Global.difficulty)):
			# 10% chance for a ship per threat above threshold
			if randi_range(1, 10) <= alien_threat - threat_threshold:
				spawn_enemy(SPINNER)
				enemy_count += 1
		if threat_threshold < cyber_threat and enemy_count < max_enemies + (2 * int(Global.difficulty)):
			# 10% chance for a ship per threat above threshold
			if randi_range(1, 10) <= alien_threat - threat_threshold:
				spawn_enemy(SNIPER)
				enemy_count += 1
				
		# now go through and spawn asteroids, proportionate to the threat level
		var asteroid_count = get_tree().get_nodes_in_group("asteroids").size()
		if asteroid_count < 3 * asteroid_threat:
			# 30% chance to spawn an asteroid, rolled once per asteroid threat level
			for i in asteroid_threat:
				if randi_range(1, 10) <= 3:
					spawn_asteroid()
		
		# now go through and spawn cargo ships, proportionate to the cargo level
		var cargo_count = get_tree().get_nodes_in_group("cargo").size()
		if cargo_count < cargo_level:
			#20% chance to spawn a cargo, rolled once per cargo level
			for i in cargo_level:
				if randi_range(1, 10) <= 2:
					spawn_cargo()
					
		# now go through and trigger some random spice blows, proportionate to the spice blow level 10% chance per spice level
		if randi_range(1, 10) <= spice_level:
			# three 40% chance rolls at various spice blows
			for i in 3:
				if randi_range(1, 10) <= 4:
					Global.spice_blow(2 + i, get_random_location())

func get_random_location() -> Vector2:
	var new_location = Vector2.ZERO
	new_location.x = randf_range(min_x, max_x)
	new_location.y = randf_range(min_y, max_y)
	return new_location
	
func spawn_cargo() -> void:
	var new_cargo = CARGO.instantiate()
	new_cargo.position.x = randf_range(min_x, max_x)
	new_cargo.position.y = randf_range(min_y, max_y)
	new_cargo.position = force_to_edge(new_cargo.position)
	new_cargo.target_point.x = randf_range(min_x, max_x)
	new_cargo.target_point.y = randf_range(min_y, max_y)
	new_cargo.target_point = force_to_edge(new_cargo.target_point)
	add_child(new_cargo)
	new_cargo.add_to_group("cargo")
	new_cargo.plot_orders()
		
func spawn_asteroid() -> void:
	var new_asteroid = ASTEROID.instantiate()
	new_asteroid.position.x = randf_range(min_x, max_x)
	new_asteroid.position.y = randf_range(min_y, max_y)
	new_asteroid.position = force_to_edge(new_asteroid.position)
	new_asteroid.target_point.x = randf_range(min_x, max_x)
	new_asteroid.target_point.y = randf_range(min_y, max_y)
	new_asteroid.target_point = force_to_edge(new_asteroid.target_point)
	new_asteroid.speed = randf_range(65, 225)
	add_child(new_asteroid)
	new_asteroid.add_to_group("asteroids")
	new_asteroid.plot_orders()


func spawn_enemy(enemy_to_spawn) -> void:
	var new_enemy = enemy_to_spawn.instantiate()
	new_enemy.position.x = randf_range(min_x, max_x)
	new_enemy.position.y = randf_range(min_y, max_y)
	new_enemy.position = force_to_edge(new_enemy.position)
	add_child(new_enemy)
	new_enemy.add_to_group("enemies")
	new_enemy.plot_orders()

func force_to_edge(v: Vector2) -> Vector2:
	var edge_roll = randi_range(1, 4)
	if edge_roll == 1: v.x = min_x
	if edge_roll == 2: v.x = max_x
	if edge_roll == 3: v.x = min_y
	if edge_roll == 4: v.x = max_y
	return v
	
func on_press_pause() -> void:
	if considering_exit == true:
		return
	Global.on_press_pause()

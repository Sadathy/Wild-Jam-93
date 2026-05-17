extends Node2D

@export var max_x = 4000
@export var min_x = -500
@export var max_y = 1000
@export var min_y = -1000

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
	
	AudioManager.play_music(music)
	
	#SIGNALS
	Global.turn_started.connect(on_new_turn)
	exit_gate.player_tried_exit.connect(on_player_exit)
	player_ship.pause.connect(on_press_pause)
	button_leave_level.pressed.connect(on_press_leave_level)
	button_keep_playing.pressed.connect(on_press_keep_playing)
	
	Global.paused = false

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
	return
		
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

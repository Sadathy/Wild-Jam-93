extends Node2D

@export var max_x = 2000
@export var min_x = -2000
@export var max_y = 1500
@export var min_y = -1500

@export var asteroid_spawn_distance = 2500
@export var asteroid_target_variance = 1000

@onready var background: Polygon2D = %Background

const SHIP = preload("res://Scenes/player_ship.tscn")
const ASTEROID = preload("res://Scenes/Interactables/asteroid.tscn")
const ENEMY_SHIP = preload("res://Scenes/Interactables/enemy_ship.tscn")
const FREIGHTER = preload("res://Scenes/Interactables/enemy_freighter.tscn")
const SPINNER = preload("res://Scenes/Interactables/spinner.tscn")
const SNIPER = preload("res://Scenes/Interactables/cyber_sniper.tscn")
const SPICE = preload("res://Scenes/Interactables/spice.tscn")

var player_ship: Node2D = null

func _ready() -> void:
	player_ship = SHIP.instantiate()
	player_ship.position = Vector2.ZERO 
	add_child(player_ship)
	player_ship.pause.connect(on_press_pause)
	
	player_ship.camera.limit_left = min_x
	player_ship.camera.limit_right = max_x
	player_ship.camera.limit_top = min_y
	player_ship.camera.limit_bottom = max_y
	
	var p_tl = Vector2(min_x + 20, max_y - 20)
	var p_tr = Vector2(max_x - 20, max_y - 20)
	var p_br = Vector2(max_x - 20, min_y + 20)
	var p_bl = Vector2(min_x + 20, min_y + 20)
	
	var p_arr = PackedVector2Array([p_tl, p_tr, p_br, p_bl])
	
	background.polygon = p_arr
	
	AudioManager.load_music(preload("res://Assets/Audio/Nova_AMBIENT_temp.ogg"),
							preload("res://Assets/Audio/Nova_BATTLE_temp.ogg"))
	
	Global.turn_started.connect(on_new_turn)
	Global.paused = false

func on_new_turn() -> void:
	var asteroid_count = int(Global.difficulty + randi_range(-3, 0))
	if asteroid_count > 0:
		# Loop through and generate a bunch of asteroids
		for i in asteroid_count:
			var new_speed = randf_range(225, 375)
			var new_origin = (Vector2.from_angle(randf() * 2 * PI) * asteroid_spawn_distance) + player_ship.position
			var new_target = (Vector2.from_angle(randf() * 2 * PI) * (((randf() - 0.5) * asteroid_target_variance))) + player_ship.position
			# Now we map the vector from the origin to the target so we can 'project past' by multiplaying it then transforming by origin position again
			new_target = ((new_target - new_origin).normalized() * 10000) + new_origin
			var new_asteroid = Global.create_interactable(ASTEROID, new_origin, new_target, new_speed)
			add_child(new_asteroid)
	var spice_count = randi_range(-2, 1)
	if spice_count > 0:
		for i in spice_count:
			var new_speed = randf_range(100, 250)
			var new_origin = (Vector2.from_angle(randf() * 2 * PI) * asteroid_spawn_distance) + player_ship.position
			var new_target = (Vector2.from_angle(randf() * 2 * PI) * (((randf() - 0.5) * asteroid_target_variance))) + player_ship.position
			new_target = ((new_target - new_origin).normalized() * 10000) + new_origin
			var new_spice = Global.create_interactable(SPICE, new_origin, new_target, new_speed)
			add_child(new_spice)
			new_spice.add_to_group("spice")
	# If our bounty exceeds certain thresholds, and there arent absurd enemy numbers, pawn more shit!!
	var enemy_count = get_tree().get_nodes_in_group("enemies").size()
	if enemy_count == 0:
		# Always have at least one enemy ship
		spawn_enemy(ENEMY_SHIP)
	if enemy_count < 30:
		if Global.bounty * (0.4 + (Global.difficulty * 0.6)) > 3150:
			# Spawn a freighter
			spawn_enemy(FREIGHTER)
		if Global.bounty * (0.4 + (Global.difficulty * 0.6)) > 2900:
			# Spawn a sniper
			spawn_enemy(SNIPER)
		if Global.bounty * (0.4 + (Global.difficulty * 0.6)) > 2650:
			# Spawn a spinner
			spawn_enemy(SPINNER)
		if Global.bounty * (0.4 + (Global.difficulty * 0.6)) > 2400:
			# Spawn a enemy ship
			spawn_enemy(ENEMY_SHIP)
		if Global.bounty * (0.4 + (Global.difficulty * 0.6)) > 2150:
			# 1 in 2 for a freighter
			if randi_range(1, 2) == 2:
				spawn_enemy(FREIGHTER)
		if Global.bounty * (0.4 + (Global.difficulty * 0.6)) > 1900:
			# 1 in 2 for a spinner
			if randi_range(1, 2) == 2:
				spawn_enemy(SPINNER)
		if Global.bounty * (0.4 + (Global.difficulty * 0.6)) > 1650:
			# 1 in 2 for a sniper
			if randi_range(1, 2) == 2:
				spawn_enemy(SNIPER)
		if Global.bounty * (0.4 + (Global.difficulty * 0.6)) > 1400:
			# 1 in 2 for a enemy ship
			if randi_range(1, 2) == 2:
				spawn_enemy(ENEMY_SHIP)
		if Global.bounty * (0.4 + (Global.difficulty * 0.6)) > 1150:
			# 1 in 3 for a freighter
			if randi_range(1, 3) == 3:
				spawn_enemy(FREIGHTER)
		if Global.bounty * (0.4 + (Global.difficulty * 0.6)) > 900:
			# 1 in 3 for a enemy ship
			if randi_range(1, 3) == 3:
				spawn_enemy(ENEMY_SHIP)
		if Global.bounty * (0.4 + (Global.difficulty * 0.6)) > 650:
			# 1 in 3 for a sniper
			if randi_range(1, 3) == 3:
				spawn_enemy(SNIPER)
		if Global.bounty * (0.4 + (Global.difficulty * 0.6)) > 400:
			# 1 in 3 for a spinner
			if randi_range(1, 3) == 3:
				spawn_enemy(SPINNER)
		if Global.bounty * (0.4 + (Global.difficulty * 0.6)) > 150:
			# 1 in 4 for a ship
			if randi_range(1, 4) == 4:
				spawn_enemy(ENEMY_SHIP)
		
		
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
	Global.on_press_pause()

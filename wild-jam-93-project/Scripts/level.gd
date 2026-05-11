extends Node2D

@export var max_x = 1500
@export var min_x = -1500
@export var max_y = 1500
@export var min_y = -1500

@export var asteroid_spawn_distance = 2500
@export var asteroid_target_variance = 1000

@onready var background: Polygon2D = %Background

const SHIP = preload("res://Scenes/player_ship.tscn")
const ASTEROID = preload("res://Scenes/Interactables/asteroid.tscn")
const ENEMY_SHIP = preload("res://Scenes/Interactables/enemy_ship.tscn")

var player_ship: Node2D = null

func _ready() -> void:
	player_ship = SHIP.instantiate()
	player_ship.position = Vector2.ZERO 
	add_child(player_ship)
	
	var p_tl = Vector2(min_x, max_y)
	var p_tr = Vector2(max_x, max_y)
	var p_br = Vector2(max_x, min_y)
	var p_bl = Vector2(min_x, min_y)
	
	var p_arr = PackedVector2Array([p_tl, p_tr, p_br, p_bl])
	
	background.polygon = p_arr
	
	AudioManager.load_music(preload("res://Assets/Audio/Nova_AMBIENT_temp.ogg"),
							preload("res://Assets/Audio/Nova_BATTLE_temp.ogg"))
	
	Global.turn_started.connect(on_new_turn)

func on_new_turn() -> void:
	var asteroid_count = Global.difficulty + randi_range(-2, 1)
	if asteroid_count > 0:
		# Loop through and generate a bunch of asteroids
		for i in asteroid_count:
			var new_speed = 300 #Giving asteroids constant speed for now
			var new_origin = Vector2.from_angle(randf() * 2 * PI) * asteroid_spawn_distance + player_ship.position
			var new_target = Vector2.from_angle(randf() * 2 * PI) * (((randf() - 0.5) * asteroid_target_variance)) + player_ship.position
			# Now we map the vector from the origin to the target so we can 'project past' by multiplaying it then transforming by origin position again
			new_target = ((new_target - new_origin).normalized() * 10000) + new_origin
			var new_asteroid = Global.create_interactable(ASTEROID, new_origin, new_target, new_speed)
			add_child(new_asteroid)

	var enemy_count = get_tree().get_nodes_in_group("enemy_ships").size()
	# Roll to generate an enemy ship, based on difficulty
	if randi_range(-1, int(Global.difficulty)) > 1 and enemy_count < Global.difficulty:
		# Create a new enemy ship
		var new_enemy = ENEMY_SHIP.instantiate()
		new_enemy.position.x = randf_range(min_x, max_x)
		new_enemy.position.y = randf_range(min_y, max_y)
		# Make sure we spawn at one extreme edge atleast:
		new_enemy.position = force_to_edge(new_enemy.position)
		add_child(new_enemy)
		new_enemy.add_to_group("enemy_ships")
	if Global.turn_count == 1 and enemy_count < Global.difficulty:
		# Create a new enemy ship
		var new_enemy = ENEMY_SHIP.instantiate()
		new_enemy.position.x = randf_range(min_x, max_x)
		new_enemy.position.y = randf_range(min_y, max_y)
		new_enemy.position = force_to_edge(new_enemy.position)
		add_child(new_enemy)
		new_enemy.add_to_group("enemy_ships")
		

func force_to_edge(v: Vector2) -> Vector2:
	var edge_roll = randi_range(1, 4)
	if edge_roll == 1: v.x = min_x
	if edge_roll == 2: v.x = max_x
	if edge_roll == 3: v.x = min_y
	if edge_roll == 4: v.x = max_y
	return v

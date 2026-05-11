extends Node2D

@export var max_x = 4500
@export var min_x = -4500
@export var max_y = 4500
@export var min_y = -4500

@export var asteroid_spawn_distance = 2500
@export var asteroid_target_variance = 1000

@onready var background: Polygon2D = %Background

const SHIP = preload("res://Scenes/player_ship.tscn")
const ASTEROID = preload("res://Scenes/Interactables/asteroid.tscn")

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
	if asteroid_count <= 0:
		return
	# Loop through and generate a bunch of asteroids
	for i in asteroid_count:
		var new_speed = 450 #Giving asteroids constant speed for now
		var new_origin = Vector2.from_angle(randf() * 2 * PI) * asteroid_spawn_distance + player_ship.position
		var new_target = Vector2.from_angle(randf() * 2 * PI) * (((randf() - 0.5) * asteroid_target_variance)) + player_ship.position
		# Now we map the vector from the origin to the target so we can 'project past' by multiplaying it then transforming by origin position again
		new_target = ((new_target - new_origin).normalized() * 10000) + new_origin
		var new_asteroid = Global.create_interactable(ASTEROID, new_origin, new_target, new_speed)
		add_child(new_asteroid)
	

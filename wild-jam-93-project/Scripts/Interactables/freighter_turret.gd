extends Node2D

@onready var sprite_swivel : Node2D = $SpriteSwivel
@export var MISSILE_SPEED: float = 450

var health : int = 100

# Art assets & loadables
const TARGET_INDICATOR_ART = preload("uid://cqe8li46sh7w2")
const TARGET_LINE_ART = preload("uid://b2k88n4s7ghoj")
const SHOOT_LINE_ART = preload("uid://be3j5g2ioln0t")

const TARGET_INDICATOR = preload("uid://dsbyr6xn56eg4")
const TARGET_LINE = preload("uid://c68eu6qksr8n5")

const ENEMY_LASER = preload("uid://8x3hw3dhpryy")

var orders: Dictionary = {}
var order_id: int = -1

var player_ship: CharacterBody2D

# Attack handling
const DEFAULT_ATTACK_COOLDOWN: float = 0.32
var attack_cooldown: float = 0

const DEFAULT_ATTACK_TIME: float = 0.99
var attack_time: float = 3

var attack_target: Vector2

var missiles_fired_this_round : int = 0

var order_indicators : Array = []

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	player_ship = Global.level.player_ship

# State machine
@onready var do_attempt_plot_attack : bool = true
@onready var need_clear : bool = false
@onready var set_do_attempt_plot_attack_on_next_player_turn = false
@onready var attacking : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if player_ship == null:
		player_ship = Global.level.player_ship
		
	if do_attempt_plot_attack:
		if randi_range(0,100) < 25:
			plot_attack()
			attacking = true
		do_attempt_plot_attack = false
		
	if Global.player_turn == true:
		if set_do_attempt_plot_attack_on_next_player_turn:
			missiles_fired_this_round = 0
			attacking = false
			do_attempt_plot_attack = true
			set_do_attempt_plot_attack_on_next_player_turn = false
		return
	
	if attacking:
		order_attack(delta)
	
	if need_clear:
		need_clear = false
		set_do_attempt_plot_attack_on_next_player_turn = true
		clear_plots()
	
	if player_ship != null:
		look_at_interpolated(attack_target)
		need_clear = true

func clear_plots():
	for indicator : Node2D in order_indicators:
		indicator.queue_free()
	order_indicators = []

func plot_attack() -> void:
	# Find this order's origin
	var order_origin = global_position
	#if order_id != 1:
	#	order_origin = orders[order_id - 1]["target"]
		
	# If we're outside threat range, plot a pursue instead
	#if order_origin.distance_to(player_ship.position) > THREAT_RANGE:
	#	plot_pursue()
	#	return
		
	# Find the player position, offset by some random distance & direction
	var desired_target = player_ship.global_position + (Vector2((randf() - 0.5) * 2, (randf() - 0.5) * 2) * randf_range(0, 300))
	
	# Project a first turn target based on max distance that the projectile will cover on this turn
	var initial_target = ((desired_target - order_origin).normalized() * (MISSILE_SPEED * (4 - order_id))) + order_origin
	
	# Project a true target some excessive distance in that direction
	var order_target = (desired_target - order_origin).normalized() * 10000 + order_origin
	
	attack_target = order_target
	
	# Create indicators for this order
	var order_indicator = TARGET_INDICATOR.instantiate()
	order_indicator.position = initial_target
	order_indicator.label = "Shoot"
	get_tree().get_root().add_child(order_indicator)
	order_indicator.sprite.texture = TARGET_INDICATOR_ART
	order_indicators.append(order_indicator)
	
	# Create lines for this order
	var order_line = TARGET_LINE.instantiate()
	order_line.set_point_position(0, order_origin)
	order_line.set_point_position(1, initial_target)
	get_tree().get_root().add_child(order_line)
	order_line.texture = SHOOT_LINE_ART
	order_line.width = 18
	order_indicators.append(order_line)
	
	# Save everything under the current order_id in the orders dictionary
	#orders[order_id] = {
	#	"order_string": "attack",
	#	"origin": order_origin,
	#	"target": order_origin,
	#	"indicator": order_indicator,
	#	"line": order_line,
	#	"attack_target": order_target
	#}

func order_attack(delta: float):
	print("Ran attack, time: ", attack_time)
	# The delegated function for if we're in an attack order, returns true if the order is complete.
	var order_target = attack_target#orders[order_id]["attack_target"]
	var order_origin = global_position#orders[order_id]["origin"]
	
	# Turn the turret towards it's attack target
	look_at_interpolated(order_target, 0.1)
	
	# Increment our attack timer / cooldown
	#attack_time -= delta
	attack_cooldown -= delta
	
	# If our attack is off cooldown, launch a missile
	if attack_cooldown <= 0 and missiles_fired_this_round < 3:
		attack_cooldown = DEFAULT_ATTACK_COOLDOWN
		var new_origin = order_origin
		var new_target = order_target
		var new_missile = Global.create_interactable(ENEMY_LASER, new_origin, new_target, MISSILE_SPEED)
		get_tree().get_root().add_child(new_missile)
		missiles_fired_this_round += 1
	
	# If our attack has finished it's time, return true (order complete) and hide this order's indicators.
	#if attack_time <= 0:
	#	print("attack_complete")
	#	orders[order_id]["indicator"].hide()
	#	orders[order_id]["line"].hide()
	#	return true
	#return false

func look_at_interpolated(t_pos : Vector2, weight : float = 0.1):
	sprite_swivel.global_rotation = lerpf(sprite_swivel.global_rotation, sprite_swivel.global_rotation + sprite_swivel.get_angle_to(t_pos), weight)

func take_damage(damage):
	health -= damage
	if health <= 0:
		queue_free()
	

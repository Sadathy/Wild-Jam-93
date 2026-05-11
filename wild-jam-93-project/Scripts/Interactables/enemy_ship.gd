extends CharacterBody2D

@export var ATTACK_DAMAGE: float = 20
@export var SPEED: float = 300
@export var HEALTH: float = 100
@export var MISSILE_SPEED: float = 450

var THREAT_RANGE = MISSILE_SPEED * Global.DEFAULT_TURN_DURATION

# Art assets & loadables
const TARGET_INDICATOR_ART = preload("uid://cqe8li46sh7w2")
const TARGET_LINE_ART = preload("uid://b2k88n4s7ghoj")
const SHOOT_LINE_ART = preload("uid://be3j5g2ioln0t")

const TARGET_INDICATOR = preload("uid://dsbyr6xn56eg4")
const TARGET_LINE = preload("uid://c68eu6qksr8n5")

@onready var sprite: Sprite2D = %Sprite

const ENEMY_LASER = preload("uid://8x3hw3dhpryy")

# This gets spawned naturally by the level

var player_ship: CharacterBody2D
var orders: Dictionary = {}
var order_id: int = -1

# Attack handling
const DEFAULT_ATTACK_COOLDOWN: float = 0.32
var attack_cooldown: float

const DEFAULT_ATTACK_TIME: float = 0.99
var attack_time: float

const ORDER_TYPE_LIBRARY: Dictionary = {
	1: "pursue",
	2: "strafe",
	3: "attack"
}

func _ready() -> void:
	player_ship = Global.level.player_ship
	Global.turn_started.connect(on_turn_start)
	
	# the level will create this on a new turn, so we'll miss the signal, run it manually on ready
	on_turn_start()

# Very simple behaviour to start -> Start of player turn, plot a move, a shoot and another move
# During processing turn -> execute that string of orders

func _physics_process(delta: float) -> void:
	# Execute orders, if we have them and if it's the processing turn
	if Global.player_turn == true or order_id == -1:
		return
	
	if execute_order_by_string(delta, orders[order_id]["order_string"]):
		order_id += 1
		if order_id > orders.size():
			order_id = -1
			clear_orders()
		elif orders[order_id]["order_string"] == "attack":
			attack_time = DEFAULT_ATTACK_TIME
			attack_cooldown = DEFAULT_ATTACK_COOLDOWN


func on_turn_start() -> void:
	# Just in case:
	clear_orders()
	# Plot orders
	for i in 3:
		order_id = i + 1
		# Randomly choose whether to pursue, strafe or attack the player
		var order_type = randi_range(1, 3)
		# plot an order based on the type of order we selected
		plot_order(ORDER_TYPE_LIBRARY[order_type])
	order_id = 1
	attack_time = DEFAULT_ATTACK_TIME
	attack_cooldown = DEFAULT_ATTACK_COOLDOWN

func clear_orders() -> void:
	# Loop through our order list, destroy any indicators then clear the list
	for key in orders:
		orders[key]["indicator"].queue_free()
		orders[key]["line"].queue_free()
	orders.clear()

#region Order Plotting
#------------------------------#
#--------ORDER PLOTTING--------#
#------------------------------#

func plot_order(order_string: String) -> void:
	# Helper function that plots an order based on the received string
	if order_string == "pursue":
		plot_pursue()
		return
	if order_string == "strafe":
		plot_strafe()
		return
	if order_string == "attack":
		plot_attack()
		return
		
func plot_pursue() -> void:	
	# Get this order's origin
	var order_origin = position
	if order_id != 1:
		order_origin = orders[order_id - 1]["target"]
	
	# If we're inside threat range, plot an attack instead
	if order_origin.distance_to(player_ship.position) < THREAT_RANGE:
		plot_attack()
		return

	# Find the player position, offset by some random distance & direction
	var desired_target = player_ship.position + (Vector2((randf() - 0.5) * 2, (randf() - 0.5) * 2) * randf_range(100, 300))
	
	# Project a target vector to it, based on using 1/3 of our turn to pursue
	var order_target = ((desired_target - order_origin).normalized() * SPEED) + order_origin
	
	# Create indicators for this order
	var order_indicator = TARGET_INDICATOR.instantiate()
	order_indicator.position = order_target
	order_indicator.label = str(order_id) + ": Move"
	get_tree().get_root().add_child(order_indicator)
	order_indicator.sprite.texture = TARGET_INDICATOR_ART
	
	# Create lines for this order
	var order_line = TARGET_LINE.instantiate()
	order_line.set_point_position(0, order_origin)
	order_line.set_point_position(1, order_target)
	get_tree().get_root().add_child(order_line)
	order_line.texture = TARGET_LINE_ART
	
	# Save everything under the current order_id in the orders dictionary
	orders[order_id] = {
		"order_string": "pursue",
		"origin": order_origin,
		"target": order_target,
		"indicator": order_indicator,
		"line": order_line
	}

func plot_strafe() -> void:
	# Find this order's origin
	var order_origin = position
	if order_id != 1:
		order_origin = orders[order_id - 1]["target"]
		
	# If we're outside threat range, plot a pursue instead
	if order_origin.distance_to(player_ship.position) > THREAT_RANGE:
		plot_pursue()
		return
	
	# Choose to strafe left or right
	var strafe_dir = 0.5*PI
	if randi_range(0, 1) == 0: strafe_dir *= -1
	
	# Create a normal vector perpendicular to vector from player -> this ship, scaled by our speed
	var a = get_angle_to(player_ship.position) + strafe_dir
	var order_target = (Vector2.from_angle(a) * (SPEED)) + order_origin

	# Create indicators for this order
	var order_indicator = TARGET_INDICATOR.instantiate()
	order_indicator.position = order_target
	order_indicator.label = str(order_id) + ": Move"
	get_tree().get_root().add_child(order_indicator)
	order_indicator.sprite.texture = TARGET_INDICATOR_ART
	
	# Create lines for this order
	var order_line = TARGET_LINE.instantiate()
	order_line.set_point_position(0, order_origin)
	order_line.set_point_position(1, order_target)
	get_tree().get_root().add_child(order_line)
	order_line.texture = TARGET_LINE_ART
	
	# Save everything under the current order_id in the orders dictionary
	orders[order_id] = {
		"order_string": "strafe",
		"origin": order_origin,
		"target": order_target,
		"indicator": order_indicator,
		"line": order_line
	}
	
func plot_attack() -> void:
	# Find this order's origin
	var order_origin = position
	if order_id != 1:
		order_origin = orders[order_id - 1]["target"]
		
	# If we're outside threat range, plot a pursue instead
	if order_origin.distance_to(player_ship.position) > THREAT_RANGE:
		plot_pursue()
		return
		
	# Find the player position, offset by some random distance & direction
	var desired_target = player_ship.position + (Vector2((randf() - 0.5) * 2, (randf() - 0.5) * 2) * randf_range(0, 300))
	
	# Project a first turn target based on max distance that the projectile will cover on this turn
	var initial_target = ((desired_target - order_origin).normalized() * (MISSILE_SPEED * (4 - order_id))) + order_origin
	
	# Project a true target some excessive distance in that direction
	var order_target = (desired_target - order_origin).normalized() * 10000 + order_origin
	
	# Create indicators for this order
	var order_indicator = TARGET_INDICATOR.instantiate()
	order_indicator.position = initial_target
	order_indicator.label = str(order_id) + ": Shoot"
	get_tree().get_root().add_child(order_indicator)
	order_indicator.sprite.texture = TARGET_INDICATOR_ART
	
	# Create lines for this order
	var order_line = TARGET_LINE.instantiate()
	order_line.set_point_position(0, order_origin)
	order_line.set_point_position(1, initial_target)
	get_tree().get_root().add_child(order_line)
	order_line.texture = SHOOT_LINE_ART
	order_line.width = 18
	
	# Save everything under the current order_id in the orders dictionary
	orders[order_id] = {
		"order_string": "attack",
		"origin": order_origin,
		"target": order_origin,
		"indicator": order_indicator,
		"line": order_line,
		"attack_target": order_target
	}
		
#endregion

#region Order Execution
#------------------------------#
#--------ORDER EXECUTION-------#
#------------------------------#

func execute_order_by_string(delta: float, order_string: String) -> bool:
	if order_string == "attack":
		return order_attack(delta)
	else:
		return order_move(delta)

func order_move(delta: float) -> bool:
	# The delegated function for if we're in a move order, returns true if the order is complete.
	var order_target = orders[order_id]["target"]
	var order_line = orders[order_id]["line"]
	
	# Turn the ship towards it's move target
	look_at_interpolated(order_target)
	
	# Move the ship towards it's move target, based on speed
	var move_dir = abs((order_target - position).normalized())
	position.x = move_toward(position.x, order_target.x, SPEED * delta * move_dir.x)
	position.y = move_toward(position.y, order_target.y, SPEED * delta * move_dir.y)
	
	# Update the position of this order's line indicator
	order_line.set_point_position(0, position)
	
	# If the ship has reached it's move target, return true (order completed) and hide this order's indicators
	if position == order_target:
		order_line.hide()
		orders[order_id]["indicator"].hide()
		return true
	return false

func order_attack(delta: float) -> bool:
	print("Ran attack, time: ", attack_time)
	# The delegated function for if we're in an attack order, returns true if the order is complete.
	var order_target = orders[order_id]["attack_target"]
	var order_origin = orders[order_id]["origin"]
	
	# Turn the ship towards it's attack target
	look_at_interpolated(order_target, 0.35)
	
	# Increment our attack timer / cooldown
	attack_time -= delta
	attack_cooldown -= delta
	
	# If our attack is off cooldown, launch a missile
	if attack_cooldown <= 0:
		attack_cooldown = DEFAULT_ATTACK_COOLDOWN
		var new_origin = order_origin
		var new_target = order_target
		var new_missile = Global.create_interactable(ENEMY_LASER, new_origin, new_target, MISSILE_SPEED)
		get_tree().get_root().add_child(new_missile)
	
	# If our attack has finished it's time, return true (order complete) and hide this order's indicators.
	if attack_time <= 0:
		print("attack_complete")
		orders[order_id]["indicator"].hide()
		orders[order_id]["line"].hide()
		return true
	return false
	
func look_at_interpolated(t_pos : Vector2, weight : float = 0.1):
	sprite.rotation = lerpf(sprite.rotation, sprite.rotation + sprite.get_angle_to(t_pos), weight)
#endregion

func take_damage(incoming_damage: float) -> void:
	if incoming_damage >= HEALTH:
		queue_free()
		return
	HEALTH -= incoming_damage

func _exit_tree() -> void:
	clear_orders()
	

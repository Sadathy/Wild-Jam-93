extends Area2D

@export var rotation_rate = 1.5

@onready var sprite_art: Sprite2D = %Sprite
@onready var sprite: Sprite2D = %Sprite
@onready var order_drift: Node = $OrderMachine/OrderDrift
@onready var order_machine: Node = %OrderMachine


var origin_point: Vector2
var target_point: Vector2
var damage: float = 20
var speed: float = 0

var max_x: float
var min_x: float
var max_y: float
var min_y: float

var HEALTH: float = 50
var immune = false

func _ready() -> void:
	# Fix our position and target point to be 'in bounds'
	max_x = Global.level.max_x
	min_x = Global.level.min_x
	max_y = Global.level.max_y
	min_y = Global.level.min_y
	origin_point.x = clamp(origin_point.x, min_x, max_x)
	origin_point.y = clamp(origin_point.y, min_y, max_y)
	target_point.x = clamp(target_point.x, min_x, max_x)
	target_point.y = clamp(target_point.y, min_y, max_y)
	
	position = origin_point
	var dir_normal = abs((target_point - position).normalized())
	order_drift.direction = dir_normal
	order_drift.speed = speed
	
	# Connect on new turn function
	order_machine.ready_for_orders.connect(on_new_turn)
	
	# Connect impact function
	body_entered.connect(on_impact)

func on_new_turn() -> void:
	#Check if we're out of bounds, if we are, destroy us!
	var out_of_bounds = false
	if position.x > max_x: out_of_bounds = true
	if position.x < min_x: out_of_bounds = true
	if position.y > max_y: out_of_bounds = true
	if position.y < min_y: out_of_bounds = true
	if out_of_bounds:
		queue_free()
		return
	order_machine.plot_order("OrderDrift")
	order_machine.plot_order("OrderDrift")
	order_machine.plot_order("OrderDrift")

func on_impact(_entering_body) -> void:
	if Global.player_turn == true:
		return
	Global.credits += 1
	queue_free()

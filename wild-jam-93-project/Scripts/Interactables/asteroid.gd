extends Area2D

@export var rotation_rate = 1.5

@onready var sprite_art: Sprite2D = %Sprite
@onready var sprite: Sprite2D = %Sprite
@onready var order_drift: Node = $OrderMachine/OrderDrift
@onready var order_machine: Node = %OrderMachine


var target_point: Vector2
var damage: float = 20
var speed: float = 50

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
	target_point.x = clamp(target_point.x, min_x, max_x)
	target_point.y = clamp(target_point.y, min_y, max_y)
	
	var dir_normal = (target_point - position).normalized()
	order_drift.direction = dir_normal
	order_drift.speed = speed
	
	# Connect on new turn function
	order_machine.ready_for_orders.connect(on_new_turn)
	
	# Connect impact function
	body_entered.connect(on_impact)
	sprite_art.finished.connect(on_damage_flash_end)

func on_new_turn() -> void:
	#Check if we're out of bounds, if we are, destroy us!
	plot_orders()
	var out_of_bounds = false
	if position.x > max_x: out_of_bounds = true
	if position.x < min_x: out_of_bounds = true
	if position.y > max_y: out_of_bounds = true
	if position.y < min_y: out_of_bounds = true
	if out_of_bounds:
		queue_free()
		return

func plot_orders() -> void:
	order_machine.plot_order("OrderDrift")
	order_machine.plot_order("OrderDrift")
	order_machine.plot_order("OrderDrift")

func on_impact(entering_body) -> void:
	if Global.player_turn == true:
		return
	if entering_body.take_damage(damage):
		queue_free()

func take_damage(incoming_damage: float) -> bool:
	if immune == true:
		return false
	if incoming_damage >= HEALTH:
		queue_free()
		return true
	HEALTH -= incoming_damage
	immune = true
	sprite_art.damage_flash()
	return true

func on_damage_flash_end() -> void:
	immune = false

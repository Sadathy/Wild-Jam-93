extends CharacterBody2D

@export var HEALTH: float = 200

@onready var sprite: Node2D = %Sprite
@onready var order_machine: Node = %OrderMachine
@onready var order_drift: Node = $OrderMachine/OrderDrift

var player_ship: CharacterBody2D

func _ready() -> void:
	player_ship = Global.level.player_ship
	order_machine.ready_for_orders.connect(plot_orders)
	order_drift.direction = (Vector2.ZERO - global_position).normalized()
	
func plot_orders() -> void:
	# Drift three times
	for i in 3:
		order_machine.plot_order("OrderDrift")

func take_damage(incoming_damage: float) -> void:
	if incoming_damage >= HEALTH:
		queue_free()
		return
	HEALTH -= incoming_damage

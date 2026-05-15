extends CharacterBody2D

@export var HEALTH: float = 75
@export var THREAT_RANGE = 400
@export var SHOOT_RANGE = 1300

@onready var sprite: Sprite2D = %Sprite
@onready var sprite_art: Sprite2D = %Sprite
@onready var order_machine: Node = %OrderMachine

var player_ship: CharacterBody2D
var immune = false
var bounty: int = 50

func _ready() -> void:
	player_ship = Global.level.player_ship
	order_machine.ready_for_orders.connect(plot_orders)
	sprite_art.finished.connect(on_damage_flash_end)
	
func plot_orders() -> void:
	# Check if we're in threat range
	if position.distance_to(player_ship.position) <= THREAT_RANGE:
		# Flee! Then try sniping
		order_machine.plot_order("OrderFlee")
		order_machine.plot_order("OrderSnipe")
	elif position.distance_to(player_ship.position) <= SHOOT_RANGE:
		# Line up a snipe, then strafe - SNIPE TAKES TWO TURNS!
		order_machine.plot_order("OrderSnipe")
		order_machine.plot_order("OrderStrafe")
	else:
		# Pursue to get into range
		order_machine.plot_order("OrderPursue")
		order_machine.plot_order("OrderPursue")
		order_machine.plot_order("OrderPursue")

func take_damage(incoming_damage: float) -> bool:
	if immune == true:
		return false
	if incoming_damage >= HEALTH:
		Global.bounty += bounty
		Global.call_deferred("spice_blow", 5, position)
		queue_free()
		return true
	HEALTH -= incoming_damage
	immune = true
	sprite_art.damage_flash()
	return true

func on_damage_flash_end() -> void:
	immune = false

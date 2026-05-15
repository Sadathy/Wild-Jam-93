extends CharacterBody2D

@export var HEALTH: float = 50
@export var THREAT_RANGE = 600

@onready var sprite: Sprite2D = %Sprite
@onready var sprite_art: Sprite2D = %Sprite
@onready var order_machine: Node = %OrderMachine

var player_ship: CharacterBody2D
var immune = false
var bounty: int = 200

func _ready() -> void:
	player_ship = Global.level.player_ship
	order_machine.ready_for_orders.connect(plot_orders)
	sprite_art.finished.connect(on_damage_flash_end)
	
func plot_orders() -> void:
	# Check if we're in threat range
	if position.distance_to(player_ship.position) <= THREAT_RANGE:
		# Do a 50/50 mix of attacks and strafes
		for i in 3:
			if randi_range(0, 1) == 1:
				order_machine.plot_order("OrderStrafe")
			else:
				order_machine.plot_order("OrderShoot")
	else:
		# Do a 75/25 mix of pursuits and attacks
		for i in 3:
			if randi_range(0, 3) == 3:
				order_machine.plot_order("OrderShoot")
			else:
				order_machine.plot_order("OrderPursue")

func take_damage(incoming_damage: float) -> bool:
	if immune == true:
		return false
	if incoming_damage >= HEALTH:
		Global.bounty += bounty
		Global.call_deferred("spice_blow", 3, position)
		queue_free()
		return true
	HEALTH -= incoming_damage
	immune = true
	sprite_art.damage_flash()
	return true

func on_damage_flash_end() -> void:
	immune = false

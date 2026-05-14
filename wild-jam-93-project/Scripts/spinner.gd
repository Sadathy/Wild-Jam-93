extends CharacterBody2D

@export var HEALTH: float = 50
@export var THREAT_RANGE = 300

@onready var sprite: Node2D = %Sprite
@onready var order_machine: Node = %OrderMachine

var player_ship: CharacterBody2D

func _ready() -> void:
	player_ship = Global.level.player_ship
	order_machine.ready_for_orders.connect(plot_orders)
	
func plot_orders() -> void:
	# Check if we're in threat range
	for i in 3:
		if order_machine.get_order_finish(i).distance_to(player_ship.position) <= THREAT_RANGE:
			# If we're nearby, we have a 50/50 chance to try and spin through the player!
			if randi_range(0, 1) == 1:
				order_machine.plot_order("OrderSpin")
			else:
				order_machine.plot_order("OrderHold")
		else:
			order_machine.plot_order("OrderPursue")

func take_damage(incoming_damage: float) -> void:
	if incoming_damage >= HEALTH:
		queue_free()
		return
	HEALTH -= incoming_damage

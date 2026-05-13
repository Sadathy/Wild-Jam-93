extends CharacterBody2D

@export var HEALTH: float = 25
@export var THREAT_RANGE = 1600

@onready var sprite: Sprite2D = %Sprite
@onready var order_machine: Node = %OrderMachine

var player_ship: CharacterBody2D

func _ready() -> void:
	player_ship = Global.level.player_ship
	order_machine.ready_for_orders.connect(plot_orders)
	
func plot_orders() -> void:
	# Check if we're in threat range
	if position.distance_to(player_ship.position) <= THREAT_RANGE:
		# Take a shot on a random point in the turn
		var shot_point = randi_range(0, 2)
		for i in 3:
			if i == shot_point:
				order_machine.plot_order("OrderShoot")
			else:
				order_machine.plot_order("OrderHold")
	else:
		# Hold
		for i in 3:
			order_machine.plot_order("OrderHold")

func take_damage(incoming_damage: float) -> void:
	if incoming_damage >= HEALTH:
		queue_free()
		return
	HEALTH -= incoming_damage

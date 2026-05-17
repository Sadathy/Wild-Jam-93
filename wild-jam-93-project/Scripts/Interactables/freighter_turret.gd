extends CharacterBody2D

@export var HEALTH: float = 50
@export var THREAT_RANGE = 1000

@onready var sprite: Sprite2D = %Sprite
@onready var order_machine: Node = %OrderMachine
@onready var sprite_art: Sprite2D = %Sprite

var player_ship: CharacterBody2D
var immune: bool = false

func _ready() -> void:
	player_ship = Global.level.player_ship
	order_machine.ready_for_orders.connect(plot_orders)
	sprite_art.finished.connect(on_damage_flash_end)
	
func plot_orders() -> void:
	# Check if we're in threat range
	if global_position.distance_to(player_ship.global_position) <= THREAT_RANGE:
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

extends CharacterBody2D

@export var HEALTH: float = 50
@export var THREAT_RANGE = 300

@onready var sprite: Node2D = %Sprite
@onready var order_machine: Node = %OrderMachine
@onready var sprite_art: Sprite2D = $Sprite/Sprite

var player_ship: CharacterBody2D
var immune: bool = false
var bounty: int = 140


func _ready() -> void:
	player_ship = Global.level.player_ship
	order_machine.ready_for_orders.connect(plot_orders)
	sprite_art.finished.connect(on_damage_flash_end)
	
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

func take_damage(incoming_damage: float) -> bool:
	if immune == true:
		return false
	if incoming_damage >= HEALTH:
		Global.bounty += bounty
		Global.call_deferred("spice_blow", 3, position)
		AudioManager.play(preload("res://Assets/Audio/VOiD1/Blast_14.wav"))
		queue_free()
		return true
	HEALTH -= incoming_damage
	immune = true
	sprite_art.damage_flash()
	return true
	
func on_damage_flash_end() -> void:
	immune = false

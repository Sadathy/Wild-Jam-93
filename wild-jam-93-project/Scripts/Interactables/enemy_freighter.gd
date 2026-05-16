extends CharacterBody2D

@export var HEALTH: float = 750

@onready var sprite: Node2D = %Sprite
@onready var sprite_art: Sprite2D = $Sprite/Sprite
@onready var order_machine: Node = %OrderMachine
@onready var order_drift: Node = $OrderMachine/OrderDrift

var player_ship: CharacterBody2D
var immune = false
var bounty: int = 600

func _ready() -> void:
	player_ship = Global.level.player_ship
	order_machine.ready_for_orders.connect(plot_orders)
	order_drift.direction = (Vector2.ZERO - global_position).normalized()
	sprite_art.finished.connect(on_damage_flash_end)
	
func plot_orders() -> void:
	# Drift three times
	for i in 3:
		order_machine.plot_order("OrderDrift")

func take_damage(incoming_damage: float) -> bool:
	if immune == true:
		return false
	if incoming_damage >= HEALTH:
		Global.bounty += bounty
		for i in 5:
			var blow_pos = position + (Vector2(randf_range(-1, 1), randf_range(-1, 1)) * randf_range(10, 100))
			Global.call_deferred("spice_blow", 3, blow_pos)
		AudioManager.play(preload("res://Assets/Audio/VOiD1/Blast_6.wav"))
		queue_free()
		return true
	HEALTH -= incoming_damage
	immune = true
	sprite_art.damage_flash()
	return true

func on_damage_flash_end() -> void:
	immune = false

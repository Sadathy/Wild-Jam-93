extends CharacterBody2D

@export var HEALTH: float = 50
#@export var THREAT_RANGE = 600

@onready var sprite: Sprite2D = %Sprite
@onready var sprite_art: Sprite2D = %Sprite
@onready var order_machine: Node = %OrderMachine

@export var THREAT_RANGE = 600

var max_x: float
var min_x: float
var max_y: float
var min_y: float


var immune = false
var bounty: int = 70

func _ready() -> void:
	order_machine.ready_for_orders.connect(plot_orders)
	sprite_art.finished.connect(on_damage_flash_end)
	max_x = Global.level.max_x
	min_x = Global.level.min_x
	max_y = Global.level.max_y
	min_y = Global.level.min_y
	
func plot_orders() -> void:
	#Check if we're out of bounds, if we are, destroy us!
	var out_of_bounds = false
	if position.x > max_x: out_of_bounds = true
	if position.x < min_x: out_of_bounds = true
	if position.y > max_y: out_of_bounds = true
	if position.y < min_y: out_of_bounds = true
	if out_of_bounds:
		queue_free()
		return
	for i in 3:
		order_machine.plot_order("OrderDrift")

func take_damage(incoming_damage: float) -> bool:
	if immune == true:
		return false
	if incoming_damage >= HEALTH:
		Global.bounty += bounty
		Global.call_deferred("spice_blow", randi_range(1,3), position)
		AudioManager.play(preload("res://Assets/Audio/VOiD1/Blast_14.wav"))
		queue_free()
		return true
	HEALTH -= incoming_damage
	immune = true
	sprite_art.damage_flash()
	return true

func on_damage_flash_end() -> void:
	immune = false

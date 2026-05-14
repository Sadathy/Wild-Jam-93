extends CharacterBody2D

@export var HEALTH: float = 200

@onready var sprite: Node2D = %Sprite
@onready var order_machine: Node = %OrderMachine
@onready var order_drift: Node = $OrderMachine/OrderDrift
@onready var boarding_scene: PackedScene = preload("uid://cyoesomt3r0bv")

var player_ship: CharacterBody2D

var vulnerable_to_boarding : bool = false
var already_boarded : bool = false

func _ready() -> void:
	player_ship = Global.level.player_ship
	order_machine.ready_for_orders.connect(plot_orders)
	order_drift.direction = (Vector2.ZERO - global_position).normalized()

func _physics_process(delta: float) -> void:
	if not vulnerable_to_boarding and sprite.all_turrets_destroyed:
		vulnerable_to_boarding = true
	if player_ship != null and vulnerable_to_boarding and not already_boarded and player_ship.global_position.distance_to(global_position) < 300:
		if Global.player_turn and Input.is_action_just_pressed("board"):
			print("TODO: IMPLEMENT BOARDING THING YO MAMA")
			already_boarded = true
			var new_boarding_scene : Node2D = boarding_scene.instantiate()
			#new_boarding_scene.z_index = 5000000
			get_tree().root.add_child(new_boarding_scene)
			Global.currently_boarding = true
		$Sprite/Label.visible = true
	else:
		$Sprite/Label.visible = false

func plot_orders() -> void:
	# Drift three times
	for i in 3:
		order_machine.plot_order("OrderDrift")

func take_damage(incoming_damage: float) -> void:
	if incoming_damage >= HEALTH:
		queue_free()
		return
	HEALTH -= incoming_damage

extends Area2D

var damage: float = 35
@onready var order_machine: Node = %OrderMachine

func _ready() -> void:
	# Connect impact function
	body_entered.connect(on_impact)
	area_entered.connect(on_impact)

func on_impact(entering_body) -> void:
	if Global.player_turn == true:
		return
	# Only do damage if we're currently spinning
	if order_machine.orders[order_machine.executing_order_id] == "OrderSpin":
		entering_body.take_damage(damage)

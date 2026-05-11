extends State

@onready var player_ship: CharacterBody2D = $"../../.."

var order_id: int = -1
var order: Dictionary = {}

func on_enter(enter_data: Dictionary = {}) -> void:
	order_id = CONTROLLER.order_id
	order = enter_data

func on_physics(delta: float) -> void:
	var dir_normal = abs((order["target"] - order["origin"]).normalized())
	var player_x = player_ship.position.x
	var player_y = player_ship.position.y
	var target = order["target"]
	
	player_x = move_toward(player_x, target.x, player_ship.speed * delta * dir_normal.x)
	player_y = move_toward(player_y, target.y, player_ship.speed * delta * dir_normal.y)
	
	# If we're attacking next, we should look at that attack target, to create a 'strafe' appearence
	if order_id != CONTROLLER.plotted_orders.size() and CONTROLLER.plotted_orders[order_id + 1]["order_string"] == "attack":
		player_ship.look_at_interpolated(CONTROLLER.plotted_orders[order_id + 1]["attack_from"], 0.5)
	else:
		player_ship.look_at_interpolated(target, 0.1)
	
	player_ship.position = Vector2(player_x, player_y)
	order["line"].set_point_position(0, player_ship.position)
	
	if player_ship.position == target:
		order["indicator"].hide()
		order["line"].hide()
		CONTROLLER.order_id += 1
		if CONTROLLER.order_id > CONTROLLER.plotted_orders.size():
			CONTROLLER.change_state(CONTROLLER.STATE_NO_ORDERS)
		else:
			CONTROLLER.change_state(CONTROLLER.STATE_LIBRARY[CONTROLLER.plotted_orders[CONTROLLER.order_id]["order_string"]], CONTROLLER.plotted_orders[CONTROLLER.order_id])

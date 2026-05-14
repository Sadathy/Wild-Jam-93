extends State

@onready var player_ship: CharacterBody2D = $"../../.."

var indicator = null
var target_line = null
var attack_line = null
var fuel_on_enter: float = 0
var order: Dictionary = {}
var order_origin: Vector2 = Vector2.ZERO

const ATTACK_LINE = preload("uid://7b8ahfruxcgl")
const TARGET_INDICATOR = preload("uid://dsbyr6xn56eg4")
const TARGET_LINE = preload("uid://c68eu6qksr8n5")

const INDICATOR_ART = preload("uid://dggyq628ewys2")
const TARGET_LINE_ART = preload("uid://cbr7hxdrlgt36")

const LINE_START = 100
const LINE_END = 10000

func on_enter(_entry_data: Dictionary = {}) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED  
	CONTROLLER.button_cancel.disabled = false
	CONTROLLER.button_cancel.show()
	CONTROLLER.button_move.disabled = true
	CONTROLLER.button_move.hide()
	CONTROLLER.button_attack.disabled = true
	CONTROLLER.button_attack.hide()
	CONTROLLER.label_orders.text = "Attacking"
	
	# Initialise data for this order
	fuel_on_enter = player_ship.fuel
	if CONTROLLER.order_id != 1:
		order_origin = CONTROLLER.plotted_orders[CONTROLLER.order_id - 1]["target"]
	else:
		order_origin = player_ship.position
	order = {}
	
	# Create our standard indicators
	target_line = TARGET_LINE.instantiate()
	target_line.set_point_position(0, order_origin)
	target_line.texture = TARGET_LINE_ART
	get_tree().get_root().add_child(target_line)
	indicator = TARGET_INDICATOR.instantiate()
	indicator.label = "Attack"
	get_tree().get_root().add_child(indicator)
	indicator.sprite.texture = INDICATOR_ART
	
	# Create our temporary targeting line
	attack_line = ATTACK_LINE.instantiate()
	get_tree().get_root().add_child(attack_line)
	
	# Deduct the fixed fuel cost of this order, for now just using the minimum fuel cost
	player_ship.fuel -= CONTROLLER.MIN_PLOT_FUEL * 3

func on_process(_delta) -> void:
	if Input.is_action_just_pressed("plot_cancel"):
		CONTROLLER.on_press_cancel()
		return
	
	# Track where the mouse is aiming
	var mouse_pos = get_global_mouse_position()
	var vector_from = ((mouse_pos - order_origin).normalized() * LINE_START) + order_origin
	var vector_to = ((mouse_pos - order_origin).normalized() * LINE_END) + order_origin
	
	# Adjust our indicators as appropriate
	attack_line.set_point_position(0, vector_from)
	attack_line.set_point_position(1, vector_to)
	
	target_line.set_point_position(1, vector_from)
	indicator.position = vector_from
	
	# If we have instructed, plot the order!
	if Input.is_action_just_pressed("plot"):
		# Create standard indicators
		var new_indicator = TARGET_INDICATOR.instantiate()
		new_indicator.position = vector_from
		new_indicator.label = str(CONTROLLER.order_id)
		get_tree().get_root().add_child(new_indicator)
		new_indicator.sprite.texture = INDICATOR_ART
		
		var new_target_line = TARGET_LINE.instantiate()
		new_target_line.set_point_position(0, order_origin)
		new_target_line.set_point_position(1, vector_from)
		get_tree().get_root().add_child(new_target_line)
		new_target_line.texture = TARGET_LINE_ART
		
		# Create attack line
		var new_attack_line = ATTACK_LINE.instantiate()
		new_attack_line.set_point_position(0, vector_from)
		new_attack_line.set_point_position(1, vector_to)
		get_tree().get_root().add_child(new_attack_line)
		
		# Find the normal vector of the attack, from the origin point, to use later - remember, this merely indicates the angle of the attack
		var attack_vector = (mouse_pos - order_origin).normalized()
		
		order = {
			"origin": order_origin,
			"target": order_origin,
			"order_string": "attack",
			"order_id": CONTROLLER.order_id,
			"indicator": new_indicator,
			"line": new_target_line,
			"fuel_cost": fuel_on_enter - player_ship.fuel,
			"attack_line": new_attack_line,
			"attack_from": vector_from,
			"attack_to": vector_to
		}
		CONTROLLER.plotted_orders[CONTROLLER.order_id] = order
		CONTROLLER.order_id += 1
		CONTROLLER.change_state(CONTROLLER.STATE_NO_PLOT)
	
func on_exit() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Cleanup our targeting indicators
	attack_line.queue_free()
	target_line.queue_free()
	indicator.queue_free()
	
	# Give back our fuel if we didn't make an order
	if order == {}: player_ship.fuel = fuel_on_enter
	
	

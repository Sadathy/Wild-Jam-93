extends CharacterBody2D

@export var speed: float = 5.0
@export var DEFAULT_PLOT_COOLDOWN: float = 0.15

@onready var sprite: Sprite2D = %Sprite
@onready var camera: Camera2D = %Camera
@onready var active_indicator: Node2D = null
@onready var active_line: Line2D = null


const TARGET_INDICATOR = preload("res://Scenes/UI/target_indicator.tscn")
const TARGET_LINE = preload("res://Scenes/UI/target_line.tscn")

var plot_cooldown = 0

var orders: Dictionary = {}

func _ready() -> void:
	camera.make_current()
	Global.turn_ended.connect(on_turn_end)
	Global.turn_started.connect(on_turn_start)
	
	active_indicator = TARGET_INDICATOR.instantiate()
	add_sibling(active_indicator)
	active_line = TARGET_LINE.instantiate()
	active_line.add_point(Vector2.ZERO, 0)
	active_line.add_point(Vector2.ZERO, 1)
	add_sibling(active_line)

func _physics_process(_delta: float) -> void:
	# We should only process physics during the environment turn, not the player's planning turn
	if Global.player_turn == true or !orders.has(1):
		return
	var current_target = orders[1]["target"]
	var current_origin = orders[1]["origin"]
	
	# Move based on our speed towards order ID 1
	var dir_normal = abs((current_target - current_origin).normalized())
	print("dir_normal is: ", dir_normal)
	position.x = move_toward(position.x, current_target.x, speed * dir_normal.x)
	position.y = move_toward(position.y, current_target.y, speed * dir_normal.y)
	
	# Redraw order line
	orders[1]["line"].set_point_position(0, position)
	
	# If we have reached order ID 1's target, remove it from the stack of order
	if position == current_target:
		remove_first_order()
	
	# If we have no more orders, go to a new turn
	if orders.size() == 0:
		Global.turn_timer -= Global.DEFAULT_TURN_DURATION
		
	
func _process(delta: float) -> void:
	# We should only process here if we're in our planning turn
	if Global.player_turn == false:
		return
	# Move the turn planner so we can see where we're planning our turn from
	active_indicator.position = get_global_mouse_position()
	active_line.set_point_position(1, active_indicator.position)
	if orders.size() == 0:
		active_line.set_point_position(0, position)
	else:
		active_line.set_point_position(0, orders[orders.size()]["target"])
		print("Orders size is: ", orders.size())
	if plot_cooldown > 0:
		plot_cooldown -= delta
	if Input.is_action_just_pressed("plot") and plot_cooldown <= 0:
		plot_cooldown = DEFAULT_PLOT_COOLDOWN
		# Run the plot order method
		plot_order(active_indicator.position)
	if Input.is_action_just_pressed("cancel") and plot_cooldown <= 0:
		plot_cooldown = DEFAULT_PLOT_COOLDOWN
		remove_last_order()

func remove_first_order() -> void:
	# Destroy graphics for our first order
	orders[1]["indicator"].queue_free()
	orders[1]["line"].queue_free()
	# Loop through and shift orders down one slot
	for key in orders:
		if key != orders.size():
			orders[key] = orders[key + 1]
			# Also update this order's label
			orders[key]["indicator"].label_order.text = str(key)
	# Erase the order at the end, because it's a duplicate of the one before it
	orders.erase(orders.size())
	
func remove_last_order() -> void:
	if orders.size() == 0:
		return
	var current_id = orders.size()
	orders[current_id]["indicator"].queue_free()
	orders[current_id]["line"].queue_free()
	orders.erase(current_id)

# Takes a target point, creates an order to that target point then returns the new order's ID
func plot_order(order_target: Vector2) -> int:
	var order_id = orders.size() + 1
	var order_origin = Vector2.ZERO
	var new_indicator: Node2D = TARGET_INDICATOR.instantiate()
	var new_line: Line2D = TARGET_LINE.instantiate()
	
	# If this is the first order, we plot it from the origin, otherwise we plot it from the last order's target
	if order_id == 1:
		order_origin = position
	else:
		order_origin = orders[order_id - 1]["target"]
	
	#plot the points for this order line
	new_line.add_point(order_origin, 0)
	new_line.add_point(order_target, 1)
	
	#position this order indicator
	new_indicator.position = order_target
	new_indicator.label = str(order_id)
	
	# Add the order to our dictionary
	orders[order_id] = {
		"origin": order_origin,
		"target": order_target,
		"indicator": new_indicator,
		"line": new_line
	}
	
	add_sibling(new_indicator)
	add_sibling(new_line)
	
	print("Created order with ID: ", order_id)
	
	return order_id	
	
func on_turn_end() -> void:
	active_indicator.hide()
	active_line.hide()
	
func on_turn_start() -> void:
	active_indicator.show()
	active_line.show()

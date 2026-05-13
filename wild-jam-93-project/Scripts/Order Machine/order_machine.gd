extends Node

# USAGE ---
# In your character body script, refer to orders by string "<name>" where <name> is the name of the order node that is a child of this machine
# When ready_for_orders fires, based on code in your character body script, add orders to this machine with plot_order(<name>) as above
# Connect to the ready_for_orders signal and use that to trigger the construction of your orders for the turn. watching the global new_turn could be breaking!
# This machine will automatically run the controlled character body through it's orders, sequentially, on the next turn, provided it has any.
# --- PLEASE: You don't need to change any of this code, just drop the OrderMachine node with this script onto your characterBody, then
# ----------- make any order types you'd like a child of this node, and configure them in the -editor- using it's export vars

@export var CONTROLLED_BODY: CharacterBody2D

var order_register: Dictionary = {}
var orders: Dictionary = {}
var plotting_order_id = 1
var executing_order_id = 1

signal ready_for_orders

func _ready() -> void:
	for child in get_children():
		order_register[str(child.name)] = child
		child.controller = self
		child.character = CONTROLLED_BODY
	print(order_register)
	
	# Connect the signal for resetting executing_order_id
	Global.turn_started.connect(on_turn_start)

# Plots an order and stores it in the orders dictionary under the next plotting_order_id. returns true if the order existed
func plot_order(order_string: String) -> bool:
	if order_register.has(order_string):	
		order_register[order_string].plot_order()
		orders[plotting_order_id] = order_string
		plotting_order_id += 1
		return true
	return false

# On physics process, calls the correct order for whichever executing_order_id we are on	
func _physics_process(delta: float) -> void:
	if Global.player_turn == true:
		return
	
	# execute_order() returns true if the order was complete
	if orders.has(executing_order_id):
		if order_register[orders[executing_order_id]].execute_order(delta):
			executing_order_id += 1

# When a new turn starts, reset our execution order id
func on_turn_start() -> void:
	executing_order_id = 1
	plotting_order_id = 1
	clear_orders()
	ready_for_orders.emit()
	
# Clears the orders dictionary and resets plotting_order_id to 1
func clear_orders() -> void:
	for key in order_register:
		order_register[key].clear_orders()
	orders.clear()
	plotting_order_id = 1
	
#------------------------------------#
#--------GLOBAL ORDER METHODS--------#
#------------------------------------#

# Returns the global position that the controlled body -should- be at when the requested order is finished, or returns the controlled body's global position if it doesnt exist
func get_order_finish(order_id: int) -> Vector2:
	if orders.has(order_id):
		return order_register[orders[order_id]].order_data[order_id]["finish"]
	else:
		return CONTROLLED_BODY.global_position
	
func _exit_tree() -> void:
	clear_orders()
	

extends State

const TIME_BAR_UNDER = preload("uid://prktvu2e1n0g")

@export var DEFAULT_STATE: State = null
@export var SUPER_STATE_EXECUTING: State = null
@export var SUPER_STATE_MENU: State = null

@export var STATE_NO_PLOT: State = null
@export var STATE_MOVE_PLOT: State = null
@export var STATE_ATTACK_PLOT: State = null

@export var MIN_PLOT_FUEL: float = 50

@onready var player_ship: CharacterBody2D = $"../.."
@onready var button_move: Button = %ButtonMove
@onready var button_attack: Button = %ButtonAttack
@onready var button_cancel: Button = %ButtonCancel
@onready var button_undo: Button = %ButtonUndo
@onready var label_orders: Label = %LabelOrders
@onready var order_buttons: VBoxContainer = %OrderButtons
@onready var bar_fuel: TextureProgressBar = %BarFuel
@onready var camera: Camera2D = %Camera



var current_state: State = null
var previous_state: State = null

var plotted_orders: Dictionary = {}
var order_id: int = 1

func _ready():
	current_state = DEFAULT_STATE
	# Set up state change signals
	button_move.pressed.connect(on_press_move)
	button_attack.pressed.connect(on_press_attack)
	button_cancel.pressed.connect(on_press_cancel)
	button_undo.pressed.connect(on_press_undo)
	
	Global.turn_ended.connect(on_press_end_turn)
	Global.turn_started.connect(on_new_turn)

func on_physics(delta: float) -> void:
	current_state.on_physics(delta)
	
func on_process(delta: float) -> void:
	bar_fuel.value = 100 - ((player_ship.fuel / player_ship.max_fuel) * 100)
	current_state.on_process(delta)
	
func on_input(event: InputEvent) -> void:
	current_state.on_input(event)
	
func on_enter(entry_data: Dictionary = {}) -> void:
	current_state = STATE_NO_PLOT
	bar_fuel.texture_under = TIME_BAR_UNDER
	order_id = 1
	player_ship.fuel = player_ship.max_fuel
	order_buttons.show()
	current_state.on_enter(entry_data)
	
func on_exit() -> void:
	button_move.disabled = true
	button_attack.disabled = true
	button_cancel.disabled = true
	button_undo.disabled = true
	current_state.on_exit()
	
func change_state(new_state: State, entry_data: Dictionary = {}) -> void:
	current_state.on_exit()
	previous_state = current_state
	current_state = new_state
	current_state.on_enter(entry_data)
	
#--------------------------#
#-----BUTTON BEHAVIOUR-----#
#--------------------------#
func on_press_move() -> void:
	if CONTROLLER.current_state != self or player_ship.fuel < MIN_PLOT_FUEL:
		return
	change_state(STATE_MOVE_PLOT)
	
func on_press_attack() -> void:
	if CONTROLLER.current_state != self or player_ship.fuel < MIN_PLOT_FUEL * 3:
		return
	change_state(STATE_ATTACK_PLOT)
func on_press_cancel() -> void:
	if CONTROLLER.current_state != self:
		return
	change_state(STATE_NO_PLOT)
	
func on_press_undo() -> void:
	if CONTROLLER.current_state != self or order_id < 2:
		return
	var order_to_remove = order_id - 1
	var fuel_to_gain = plotted_orders[order_to_remove]["fuel_cost"]
	
	# For this order, emove the standard indicators
	var indicator_to_remove = plotted_orders[order_to_remove]["indicator"]
	var line_to_remove = plotted_orders[order_to_remove]["line"]
	indicator_to_remove.queue_free()
	line_to_remove.queue_free()
		
	# If this order was an attack, remove the attack-related indicator
	if plotted_orders[order_to_remove]["order_string"] == "attack":
		plotted_orders[order_to_remove]["attack_line"].queue_free()
	
	# Give back the fuel cost of this order
	player_ship.fuel += fuel_to_gain
	
	# Remove this order from the queue and go back to plotting this order again
	plotted_orders.erase(order_to_remove)
	order_id = order_to_remove
	
	if player_ship.fuel > MIN_PLOT_FUEL:
		bar_fuel.texture_under = TIME_BAR_UNDER
		
	# Set our camera back to where it should be
	# If we have an order, tell the camera to move to the last order's target
	if order_id != 1:
		camera.desired_position = (plotted_orders[order_id - 1]["target"] - player_ship.position)
	else:
		camera.desired_position = Vector2.ZERO
	
	button_move.disabled = false
	button_attack.disabled = false
		
func on_press_end_turn() -> void:
	if CONTROLLER.current_state != self:
		return
	CONTROLLER.change_super_state(SUPER_STATE_EXECUTING, plotted_orders)
	
func on_new_turn() -> void:
	# Need to clean up all our old orders if we have any
	for key in plotted_orders:
		plotted_orders[key]["indicator"].queue_free()
		plotted_orders[key]["line"].queue_free()
		# If this order was an attack, remove the attack-related indicator
		if plotted_orders[key]["order_string"] == "attack":
			plotted_orders[key]["attack_line"].queue_free()
	plotted_orders.clear()

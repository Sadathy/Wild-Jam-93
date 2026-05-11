extends State

@export var DEFAULT_STATE: State = null
@export var SUPER_STATE_PLOTTING: State = null
@export var SUPER_STATE_MENU: State = null

@export var STATE_NO_ORDERS: State = null
@export var STATE_ATTACK: State = null
@export var STATE_MOVE: State = null

@onready var order_buttons: VBoxContainer = %OrderButtons

var STATE_LIBRARY: Dictionary = {}

@onready var player_ship: CharacterBody2D = $"../.."

var current_state: State = null
var previous_state: State = null

var plotted_orders: Dictionary = {}
var order_id: int = 1

func _ready():
	current_state = DEFAULT_STATE
	
	Global.turn_started.connect(on_new_turn)
	
	STATE_LIBRARY = {
	"move": STATE_MOVE,
	"attack": STATE_ATTACK,
	"none": STATE_NO_ORDERS
}

func on_physics(delta: float) -> void:
	if player_ship.hp <= 0:
		CONTROLLER.change_super_state(SUPER_STATE_MENU, {"dead": true})
		return
	current_state.on_physics(delta)
	
func on_process(delta: float) -> void:
	current_state.on_process(delta)
	
func on_input(event: InputEvent) -> void:
	current_state.on_input(event)

func on_enter(entry_data: Dictionary = {}) -> void:
	plotted_orders = entry_data
	order_id = 1
	if entry_data != {}:
		change_state(STATE_LIBRARY[plotted_orders[order_id]["order_string"]], plotted_orders[order_id])
		return
	change_state(STATE_NO_ORDERS)

func change_state(new_state: State, entry_data: Dictionary = {}) -> void:
	print("Leaving state: ", current_state)
	current_state.on_exit()
	previous_state = current_state
	print("Entering state:", new_state)
	current_state = new_state
	current_state.on_enter(entry_data)
	
func on_new_turn() -> void:
	if CONTROLLER.current_state != self:
		return
	CONTROLLER.change_super_state(SUPER_STATE_PLOTTING)

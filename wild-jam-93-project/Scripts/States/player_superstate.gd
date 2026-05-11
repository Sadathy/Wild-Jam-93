extends Node

@export var DEFAULT_STATE: State = null

var current_state: State = null
var previous_state: State = null

func _ready():
	current_state = DEFAULT_STATE

func _physics_process(delta: float) -> void:
	current_state.on_physics(delta)
	
func _process(delta: float) -> void:
	current_state.on_process(delta)
	
func _unhandled_input(event: InputEvent) -> void:
	current_state.on_input(event)

func change_super_state(new_state: State, entry_data: Dictionary = {}) -> void:
	current_state.on_exit()
	previous_state = current_state
	current_state = new_state
	current_state.on_enter(entry_data)

	

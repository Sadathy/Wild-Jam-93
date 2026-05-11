extends State

@export var DEFAULT_STATE: State = null
@export var STATE_DEAD: State = null

var current_state: State = null
var previous_state: State = null

func _ready():
	current_state = DEFAULT_STATE

func on_physics(delta: float) -> void:
	current_state.on_physics(delta)
	
func on_process(delta: float) -> void:
	current_state.on_process(delta)
	
func on_input(event: InputEvent) -> void:
	current_state.on_input(event)
	
func on_enter(entry_data: Dictionary = {}) -> void:
	if entry_data.has("dead"):
		current_state = STATE_DEAD
	current_state.on_enter(entry_data)

func change_state(new_state: State, entry_data: Dictionary = {}) -> void:
	print("Leaving state: ", current_state)
	current_state.on_exit()
	previous_state = current_state
	print("Entering state:", new_state)
	current_state = new_state
	current_state.on_enter(entry_data)

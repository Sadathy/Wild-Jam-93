class_name State extends Node2D

@export var CONTROLLER: Node = null

# This occurs when the state is first entered
func on_enter(_entry_data: Dictionary = {}) -> void:
	pass

# This occurs when the state is exited
func on_exit() -> void:
	pass

# This occurs when an unhandled input is delegated to this state
func on_input(_event) -> void:
	pass

# This occurs when the process method is delegated to this state
func on_process(_delta) -> void:
	pass

# This occurs when the physics_process method is delegated to this state
func on_physics(_delta) -> void:
	pass

	

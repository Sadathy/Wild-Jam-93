extends Area2D

var controlled_node: Node2D

@export var OrderMachine: Node


func _ready() -> void:
	controlled_node = get_parent()
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	
func on_mouse_entered() -> void:
	print("Mouse entered focus area for: ", controlled_node.name)
	OrderMachine.desired_alpha = 255

func on_mouse_exited() -> void:
	print("Mouse exited focus area for: ", controlled_node.name)
	OrderMachine.desired_alpha = 60
	

extends Node2D

@export var rotation_rate = 0.25 * PI

func _process(delta: float) -> void:
	rotation += delta * rotation_rate

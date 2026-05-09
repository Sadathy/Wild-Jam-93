extends Node2D

@export var rotation_speed: float = 25.0

@onready var sprite: Sprite2D = %Sprite

func _physics_process(delta: float) -> void:
		sprite.rotation += deg_to_rad(delta * rotation_speed)

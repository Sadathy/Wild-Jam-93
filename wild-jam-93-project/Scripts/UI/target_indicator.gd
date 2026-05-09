extends Node2D

@export var rotation_speed: float = 25.0
@export var label: String = "Move"

@onready var sprite: Sprite2D = %Sprite
@onready var label_order: Label = %LabelOrder

func _ready() -> void:
	label_order.text = label

func _physics_process(delta: float) -> void:
		sprite.rotation += deg_to_rad(delta * rotation_speed)

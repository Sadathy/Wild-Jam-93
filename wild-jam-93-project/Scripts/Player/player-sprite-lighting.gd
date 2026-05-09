extends Node2D

@export var lighting_angle_offset : int

@onready var lit_from_back : Sprite2D = $LitFromBack
@onready var lit_from_front : Sprite2D = $LitFromFront
@onready var lit_from_left : Sprite2D = $LitFromLeft
@onready var lit_from_right : Sprite2D = $LitFromRight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Modulation for "Lit From Back"
	lit_from_back.modulate.a = -cos(global_rotation + deg_to_rad(lighting_angle_offset))
	# Modulation for "Lit From Front"
	lit_from_front.modulate.a = cos(global_rotation + deg_to_rad(lighting_angle_offset))
	# Modulation for "Lit From Left"
	lit_from_left.modulate.a = sin(global_rotation + deg_to_rad(lighting_angle_offset))
	# Modulation for "Lit From Right"
	lit_from_right.modulate.a = -sin(global_rotation + deg_to_rad(lighting_angle_offset))

extends Node2D

@onready var background: Polygon2D = %Background

var max_x = 2000
var min_x = -2000
var max_y = 2000
var min_y = -2000

func _ready() -> void:
	var p_arr = PackedVector2Array([Vector2(min_x, max_y), Vector2(max_x, max_y), Vector2(max_x, min_y), Vector2(min_x, min_y)])
	background.polygon = p_arr

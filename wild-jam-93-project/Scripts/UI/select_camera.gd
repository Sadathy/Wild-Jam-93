extends Camera2D

@onready var level_select: Node2D = $"../.."

func _ready() -> void:
	limit_right = level_select.max_x
	limit_left = level_select.min_x
	limit_bottom = level_select.max_y
	limit_top = level_select.min_y

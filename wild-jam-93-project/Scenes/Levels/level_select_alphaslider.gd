extends CanvasItem

var desired_alpha: float = 0
var current_alpha: float = 0

@export var fade_rate: float = 2.0

func _process(delta: float) -> void:
	if current_alpha == desired_alpha:
		return
	current_alpha = move_toward(current_alpha, desired_alpha, fade_rate * delta)
	modulate = Color(1, 1, 1, current_alpha)

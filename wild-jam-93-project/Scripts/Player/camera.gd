extends Camera2D

@export var max_zoom = 1.5
@export var min_zoom = 0.5
@export var inc_zoom = 0.3
@export var rate_zoom = 0.6

var zoom_target = 1.0

func _ready() -> void:
	make_current()
	limit_left = Global.level.min_x
	limit_top = Global.level.max_y
	limit_right = Global.level.max_x
	limit_bottom = Global.level.min_y

# Scroll mouse when the wheel is scrolled
func _process(delta: float ) -> void:
	if Input.is_action_just_pressed("zoom_in"):
		zoom_target += inc_zoom
	if Input.is_action_just_pressed("zoom_out"):
		zoom_target -= inc_zoom

	zoom_target = clamp(zoom_target, min_zoom, max_zoom)
	
	zoom.x = move_toward(zoom.x, zoom_target, rate_zoom * delta)
	zoom.y = move_toward(zoom.y, zoom_target, rate_zoom * delta)

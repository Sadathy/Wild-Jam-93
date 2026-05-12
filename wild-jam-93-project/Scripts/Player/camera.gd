extends Camera2D

@export var max_zoom = 1.5
@export var min_zoom = 0.5
@export var inc_zoom = 0.3
@export var rate_zoom = 0.6
@export var camera_panning_amount = 0.05

var zoom_target = 1.0
var desired_position = position
var interpolate_time = 0.33
var interpolate_speed = 0
var speed_set = false

func _ready() -> void:
	make_current()
	limit_left = Global.level.min_x
	limit_top = Global.level.min_y
	limit_right = Global.level.max_x
	limit_bottom = Global.level.max_y

# Scroll mouse when the wheel is scrolled
func _process(delta: float ) -> void:
	if Input.is_action_just_pressed("zoom_in"):
		zoom_target += inc_zoom
	if Input.is_action_just_pressed("zoom_out"):
		zoom_target -= inc_zoom

	zoom_target = clamp(zoom_target, min_zoom, max_zoom)
	
	zoom.x = move_toward(zoom.x, zoom_target, rate_zoom * delta)
	zoom.y = move_toward(zoom.y, zoom_target, rate_zoom * delta)
	
	# Interpolate camera towards the target
	if position != desired_position:
		if speed_set == false:
			interpolate_speed = position.distance_to(desired_position) / interpolate_time
			speed_set = true
		var dir_normal = abs((desired_position - position).normalized())
		position.x = move_toward(position.x, desired_position.x, interpolate_speed * delta * dir_normal.x)
		position.y = move_toward(position.y, desired_position.y, interpolate_speed * delta * dir_normal.y)
		if position == desired_position:
			speed_set = false
	
	position = (get_local_mouse_position() * camera_panning_amount) + (desired_position * (1-camera_panning_amount))

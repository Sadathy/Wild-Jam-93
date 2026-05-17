extends Node2D

@onready var level_select: Node2D = $".."

@export var pan_box_x = 448
@export var pan_box_y = 252
@export var pan_factor = 0.1
@export var pan_rate = 100

var pan_time: float = 0
var camera_panning_amount: float = 0.08

var pan_y = 0
var pan_x = 0

var max_x: float
var min_x: float
var max_y: float
var min_y: float

func _ready() -> void:
	max_x = level_select.max_x
	min_x = level_select.min_x
	max_y = level_select.max_y
	min_y = level_select.min_y

func _process(delta: float) -> void:
	# Pan camera desired position towrds the edges
	var local_mouse_pos = get_local_mouse_position()
	local_mouse_pos.x = move_toward(local_mouse_pos.x, 0, pan_box_x)
	local_mouse_pos.y = move_toward(local_mouse_pos.y, 0, pan_box_y)
	if abs(local_mouse_pos.x) > 0 or abs(local_mouse_pos).y > 0:
		pan_time += delta
	else:
		pan_time = 0
	local_mouse_pos *= 1 + (pan_time * pan_time)
	position = (local_mouse_pos * camera_panning_amount) + (position * (1-camera_panning_amount))
	clamp_position()
	
func clamp_position() -> void:
	if position.x > max_x: position.x = max_x
	if position.x < min_x: position.x = min_x
	if position.y > max_y: position.y = max_y
	if position.y < min_y: position.y = min_y

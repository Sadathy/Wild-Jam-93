extends Node2D

@export var speed: float = 1.0

@onready var sprite: Sprite2D = $Sprite

const TARGET_INDICATOR = preload("res://Scenes/UI/target_indicator.tscn")
const TARGET_LINE = preload("res://Scenes/UI/target_line.tscn")

var target_pos: Vector2 = Vector2.ZERO
var move_normal: Vector2 = Vector2.ZERO
var indicators: Dictionary = {}

func _ready() -> void:
	Global.turn_ended.connect(set_move_target)
	indicators[1] = {
		"indicator": TARGET_INDICATOR.instantiate(),
		"line": TARGET_LINE.instantiate()
		}
	indicators[1]["line"].add_point(position, 0)
	indicators[1]["line"].add_point(get_viewport().get_mouse_position(), 1)
	add_sibling(indicators[1]["indicator"])
	add_sibling(indicators[1]["line"])
	

func _physics_process(_delta: float) -> void:
	if Global.player_turn == true:
		indicators[1]["indicator"].position = get_viewport().get_mouse_position()
		
		indicators[1]["line"].set_point_position(0, position)
		indicators[1]["line"].set_point_position(1, indicators[1]["indicator"].position)
		return
	
	indicators[1]["indicator"].position = target_pos
	indicators[1]["line"].set_point_position(0, position)
	indicators[1]["line"].set_point_position(1, indicators[1]["indicator"].position)
	
	position.x = move_toward(position.x, target_pos.x, speed * move_normal.x)
	position.y = move_toward(position.y, target_pos.y, speed * move_normal.y)
	
	# If we reached our destination, end the turn early
	if position == target_pos:
		Global.turn_timer -= Global.DEFAULT_TURN_DURATION
	
func set_move_target() -> void:
	target_pos = get_viewport().get_mouse_position()
	# We just make this normal so we can scale our movement in x / y relative to the angle.
	move_normal = abs((target_pos - position).normalized())
	
	if target_pos.x > position.x:
		sprite.look_at(target_pos)
	else:
		# Find vector from ship to mouse
		var dir = target_pos - position
		# Find vector from ship to new position
		dir *= -1
		# Find vector from origin to new position (A -> B = B - A, so our new dir is what we woudl get if we subtracted vector we want from origin -> ship
		dir = dir + position
		sprite.look_at(dir)
		
	# Clamp rotation a little so we don't look silly
	sprite.rotation = clamp(sprite.rotation, deg_to_rad(-45), deg_to_rad(45))
	

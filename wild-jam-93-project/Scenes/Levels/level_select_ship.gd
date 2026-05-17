extends Node2D

@onready var pivot_orbiting: Node2D = %PivotOrbiting
@onready var flying: Sprite2D = %Flying

@export var speed: float = 150
var target_pos: Vector2 = Vector2.ZERO
var flying_to_target: bool = false

signal reached_next_stage

func _ready() -> void:
	return
	
func show_orbit() -> void:
	pivot_orbiting.show()
	flying.hide()

func show_flying() -> void:
	pivot_orbiting.hide()
	flying.show()

func set_target(new_target: Vector2) -> void:
	print("Received new target: ", new_target)
	target_pos = new_target
	flying_to_target = true
	return

func _process(delta: float) -> void:
	if flying_to_target == false:
		return
	position = position.move_toward(target_pos, delta * speed)
	if position == target_pos:
		reached_next_stage.emit()
		show_orbit()

extends Area2D

@export var rotation_rate = 1.5

@onready var sprite_art: Sprite2D = %Sprite
@onready var sprite: Sprite2D = %Sprite


var origin_point: Vector2
var target_point: Vector2
var damage: float = 20
var speed: float = 0

var max_x: float
var min_x: float
var max_y: float
var min_y: float

var HEALTH: float = 50
var immune = false

func _ready() -> void:
	
	# Connect impact function
	body_entered.connect(on_impact)

func on_impact(_entering_body) -> void:
	if Global.player_turn == true:
		return
	Global.credits += 1
	Global.level.tutorial_step += 1
	queue_free()

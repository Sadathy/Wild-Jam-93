extends Node2D

@export var max_x = 1500
@export var min_x = -1500
@export var max_y = 1500
@export var min_y = -1500

@onready var background: Polygon2D = %Background

const SHIP = preload("res://Scenes/player_ship.tscn")


var player_ship: Node2D = null

func _ready() -> void:
	player_ship = SHIP.instantiate()
	player_ship.position = Vector2.ZERO 
	add_sibling(player_ship)
	
	var p_tl = Vector2(min_x, max_y)
	var p_tr = Vector2(max_x, max_y)
	var p_br = Vector2(max_x, min_y)
	var p_bl = Vector2(min_x, min_y)
	
	var p_arr = PackedVector2Array([p_tl, p_tr, p_br, p_bl])
	
	background.polygon = p_arr

	
	

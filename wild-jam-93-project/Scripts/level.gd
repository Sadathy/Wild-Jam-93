extends Node2D

@export var level_size = 1500

@onready var background: TextureRect = %Background

const SHIP = preload("res://Scenes/player_ship.tscn")


var player_ship: Node2D = null

func _ready() -> void:
	player_ship = SHIP.instantiate()
	player_ship.position = Vector2.ZERO 
	add_sibling(player_ship)
	
	background.custom_minimum_size = Vector2(level_size * 2, level_size * 2)

	
	

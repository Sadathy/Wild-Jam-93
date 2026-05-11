extends Node2D

@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("BoardingPlayer")

var visible_on_screen : bool = false
var collected : bool = false
var disappear_timer : int = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (player.global_position.distance_to(global_position) < 1000):
		visible_on_screen = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if visible_on_screen:
		if player.global_position.distance_to(global_position) < 70:
			collected = true
	if collected:
		scale *= 0.9
		global_position = (global_position * 0.9) + (player.global_position * 0.1)
		disappear_timer -= 1
		if disappear_timer < 0:
			player.money += 100
			queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	visible_on_screen = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	visible_on_screen = false

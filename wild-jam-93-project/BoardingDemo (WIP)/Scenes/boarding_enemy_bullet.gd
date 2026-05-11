extends Area2D

@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("BoardingPlayer")
@onready var movement_vector : Vector2

var lifespan : int = 1000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if lifespan >= 990:
		movement_vector = (player.global_position - global_position).normalized()
	global_position += movement_vector * 4
	lifespan -= 1
	if lifespan <= 0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("BoardingEnemy"):
		return
	elif body.is_in_group("BoardingPlayer"):
		body.health -= 1
	queue_free()

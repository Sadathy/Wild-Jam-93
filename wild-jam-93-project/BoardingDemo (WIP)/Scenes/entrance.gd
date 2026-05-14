extends Sprite2D

@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("BoardingPlayer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.global_position.distance_to(global_position) < 100:
		if Input.is_action_just_pressed("interact"):
			Global.currently_boarding = false
			get_parent().queue_free()

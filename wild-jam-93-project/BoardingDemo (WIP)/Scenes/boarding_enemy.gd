extends CharacterBody2D

@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("BoardingPlayer")

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

const bullet_scene : PackedScene = preload("../Scenes/boarding_enemy_bullet.tscn")

var timer : int = 100

func _physics_process(delta: float) -> void:
	velocity.x = move_toward(0, global_position.x - player.global_position.x, -80)
	velocity.y = move_toward(0, global_position.y - player.global_position.y, -80)
	timer -= 1
	if timer <= 0:
		var new_bullet : Node2D = bullet_scene.instantiate()
		get_parent().add_child(new_bullet)
		new_bullet.global_position = global_position
		timer = randi_range(10, 500)
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

extends Node2D

#var order_id: int = -1

@onready var travel_direction_vector = Vector2.ZERO#Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
@onready var SPEED = 1
@onready var time_to_jump : int = randi_range(1500, 3000)

var jump_timer : int = 0


var player_ship: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_at(global_position + travel_direction_vector)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if player_ship == null:
		player_ship = Global.level.player_ship
		if player_ship != null:
			travel_direction_vector = (player_ship.global_position - global_position).normalized()
			look_at(global_position + travel_direction_vector)
	# Execute orders, if we have them and if it's the processing turn
	if Global.player_turn == true:# or order_id == -1:
		return
	global_position = global_position.move_toward(global_position + (travel_direction_vector * SPEED), SPEED) 
	jump_timer += 1
	print(jump_timer)
	if jump_timer > time_to_jump:
		SPEED *= 1.1
		if jump_timer > time_to_jump + 300:
			queue_free()
		

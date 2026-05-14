extends Area2D

var origin_point: Vector2
var target_point: Vector2
var speed: float
var damage: float = 25

var max_x: float
var min_x: float
var max_y: float
var min_y: float

func _ready() -> void:
	# Fix our position and target point to be 'in bounds'
	max_x = Global.level.max_x
	min_x = Global.level.min_x
	max_y = Global.level.max_y
	min_y = Global.level.min_y
	#origin_point.x = clamp(origin_point.x, min_x, max_x)
	#origin_point.y = clamp(origin_point.y, min_y, max_y)
	#target_point.x = clamp(target_point.x, min_x, max_x)
	#target_point.y = clamp(target_point.y, min_y, max_y)
	
	position = origin_point
	
	# Connect on new turn function
	Global.turn_started.connect(on_new_turn)
	
	# Connect impact function
	area_entered.connect(on_impact)
	body_entered.connect(on_impact)
	
	#Face where we're going
	look_at(target_point)
	
func _physics_process(delta: float) -> void:
	# Only process physics for this outside of the player turn
	if Global.player_turn == true:
		return
	
	# Move based on our speed towards out target point
	var dir_normal = abs((target_point - position).normalized())
	position.x = move_toward(position.x, target_point.x, speed * dir_normal.x * delta)
	position.y = move_toward(position.y, target_point.y, speed * dir_normal.y * delta)

func on_new_turn() -> void:
	#Check if we're out of bounds, if we are, destroy us!
	var out_of_bounds = false
	if position.x > max_x: out_of_bounds = true
	if position.x < min_x: out_of_bounds = true
	if position.y > max_y: out_of_bounds = true
	if position.y < min_y: out_of_bounds = true
	if out_of_bounds:
		queue_free()

func on_impact(entering_body) -> void:
	if Global.player_turn == true:
		return
	if entering_body.take_damage(damage):
		queue_free()

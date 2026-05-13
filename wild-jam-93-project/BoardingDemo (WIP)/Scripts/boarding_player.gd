extends CharacterBody2D

@onready var money_label : Label = $Camera2D/MoneyLabel
@onready var health_label : Label = $Camera2D/HealthLabel

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var money : int = 0
var health : int = 10

var moving : bool = false

func _physics_process(delta: float) -> void:
	if health <= 0:
		visible = false
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var lr_direction := Input.get_axis("ui_left", "ui_right")
	var ud_direction := Input.get_axis("ui_up", "ui_down")
	
	moving = false
	
	if lr_direction:
		velocity.x = lr_direction
		moving = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if ud_direction:
		velocity.y = ud_direction
		moving = true
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	velocity = velocity.normalized() * SPEED
	
	money_label.text = "$" + str(money)
	health_label.text = "Health: " + str(health)

	move_and_slide()

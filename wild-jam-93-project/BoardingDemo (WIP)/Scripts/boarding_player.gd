extends CharacterBody2D

@onready var money_label : Label = $Camera2D/MoneyLabel
@onready var health_label : Label = $Camera2D/HealthLabel
@onready var sprite : Sprite2D = $Sprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var money : int = 0
var health : int = 10

var moving : bool = false

var sprite_timer : int = 0
var sprite_timer_interval : int = 10
var sprite_state : bool = false
var leg_flag : bool = false

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
	
	if moving:
		sprite_timer += 1
	
	if sprite_timer > sprite_timer_interval:
		sprite_timer = 0
		sprite_state = not sprite_state
		
		if ud_direction < 0:
			if sprite_state:
				sprite.frame = 7
			else:
				sprite.frame = 6
		elif ud_direction > 0:
			if sprite_state:
				sprite.frame = 5
			else:
				sprite.frame = 4
		elif lr_direction < 0:
			sprite.scale.x = -1.594
			if sprite_state:
				if leg_flag:
					sprite.frame = 1
				else:
					sprite.frame = 2
				leg_flag = not leg_flag
			else:
				sprite.frame = 3
		elif lr_direction > 0:
			sprite.scale.x = 1.594
			if sprite_state:
				if leg_flag:
					sprite.frame = 1
				else:
					sprite.frame = 2
				leg_flag = not leg_flag
			else:
				sprite.frame = 3
	if lr_direction == 0 and ud_direction == 0:
		sprite.frame = 0
		
	print(lr_direction)
		
		
	
	velocity = velocity.normalized() * SPEED
	
	money_label.text = "$" + str(money)
	health_label.text = "Health: " + str(health)

	move_and_slide()

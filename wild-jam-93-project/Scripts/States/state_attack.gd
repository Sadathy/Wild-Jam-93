extends State

@onready var player_ship: CharacterBody2D = $"../../.."

const PLAYER_LASER = preload("uid://dl8whwu541g6w")
const DEFAULT_COOLDOWN = 1.2

const LASER_SOUND_LIBRARY: Dictionary = {
	1:preload("uid://cnx6yobdgbde0"),
	2:preload("uid://rns3lnatu5pu"),
	3:preload("uid://cp1pswtn2153p"),
	4:preload("uid://4l1vabmdac5l")
}

var order_id: int = -1
var order: Dictionary = {}
var timer: float = -1
var cooldown = 0

func on_enter(enter_data: Dictionary = {}) -> void:
	order_id = CONTROLLER.order_id
	order = enter_data
	order["attack_line"].hide()
	timer = order["fuel_cost"] / player_ship.speed
	cooldown = 0

func on_physics(delta: float) -> void:
	player_ship.look_at_interpolated(order["attack_from"], 1)
	
	# Check if we can fire
	cooldown -= delta
	if cooldown <= 0:
		cooldown += DEFAULT_COOLDOWN
		var new_speed = 900 # Giving lasers a constant speed for now
		var new_origin = order["attack_from"]
		var new_target = order["attack_to"]
		var new_projectile = Global.create_interactable(PLAYER_LASER, new_origin, new_target, new_speed)
		get_tree().get_root().add_child(new_projectile)
		
		# Play sound for this attack
		var rand_i = randi_range(1, 4)
		AudioManager.play(LASER_SOUND_LIBRARY[rand_i])
	
	# Check if this state is over
	timer -= delta
	
	if timer <= 0:
		order["indicator"].hide()
		order["line"].hide()
		CONTROLLER.order_id += 1
		if CONTROLLER.order_id > CONTROLLER.plotted_orders.size():
			CONTROLLER.change_state(CONTROLLER.STATE_NO_ORDERS)
		else:
			CONTROLLER.change_state(CONTROLLER.STATE_LIBRARY[CONTROLLER.plotted_orders[CONTROLLER.order_id]["order_string"]], CONTROLLER.plotted_orders[CONTROLLER.order_id])

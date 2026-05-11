extends CharacterBody2D

@export var speed: float = 300.0
@export var DEFAULT_MAX_HP: float = 100

@onready var sprite: Sprite2D = %Sprite
@onready var bar_health: TextureProgressBar = %BarHealth
@onready var button_retry: Button = %ButtonRetry
@onready var button_main_menu: Button = %ButtonMainMenu



var plot_cooldown = 0

var orders: Dictionary = {}
var fuel: float = 0
var max_fuel: float = 0

var alive = true
var max_hp: float
var hp: float

func _ready() -> void:
	max_hp = DEFAULT_MAX_HP
	hp = max_hp
	max_fuel = speed * Global.DEFAULT_TURN_DURATION
	fuel = max_fuel
	
	#Connect ui buttons
	button_retry.pressed.connect(Global.pressed_retry)
	button_main_menu.pressed.connect(Global.pressed_main_menu)

func look_at_interpolated(t_pos : Vector2, weight : float = 0.1):
	sprite.rotation = lerpf(sprite.rotation, sprite.rotation + sprite.get_angle_to(t_pos) - (PI*0.5), weight)
	
#-----------------------------------#
#----------DAMAGE HANDLING----------#
#-----------------------------------#

func take_damage(incoming_damage: float) -> void:
	hp -= incoming_damage
	bar_health.value = hp
	if hp <= 0:
		alive = false
	
	
	

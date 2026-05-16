extends CharacterBody2D

@export var speed: float = 300.0
@export var DEFAULT_MAX_HP: float = 100

@onready var sprite: Sprite2D = %Sprite
@onready var sprite_art: Sprite2D = %Sprite
@onready var bar_health: TextureProgressBar = %BarHealth
@onready var button_retry: Button = %ButtonRetry
@onready var button_main_menu: Button = %ButtonMainMenu
@onready var menu_pause: PanelContainer = %MenuPause
@onready var difficulty_slider: HSlider = %DifficultySlider
@onready var volume_slider: HSlider = %VolumeSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var button_quit_run: Button = %ButtonQuitRun
@onready var button_unpause: Button = %ButtonUnpause
@onready var button_end_turn: Button = %ButtonEndTurn
@onready var camera: Camera2D = %Camera
@onready var bar_fuel: TextureProgressBar = %BarFuel


var plot_cooldown = 0

var orders: Dictionary = {}
var fuel: float = 0
var max_fuel: float = 0

var alive = true
var max_hp: float
var hp: float
var immune: bool = false

signal player_died
signal pause

func _ready() -> void:
	max_hp = DEFAULT_MAX_HP
	hp = max_hp
	max_fuel = speed * Global.DEFAULT_TURN_DURATION
	fuel = max_fuel
	
	#Connect ui buttons
	button_retry.pressed.connect(Global.pressed_retry)
	button_main_menu.pressed.connect(Global.pressed_main_menu)
	sprite_art.finished.connect(on_damage_flash_end)
	
	button_quit_run.pressed.connect(Global.pressed_main_menu)
	button_unpause.pressed.connect(on_pressed_pause)
	button_end_turn.pressed.connect(on_press_next_turn)
	
	difficulty_slider.drag_ended.connect(difficulty_changed)
	volume_slider.value_changed.connect(volume_master_changed)
	music_slider.value_changed.connect(volume_music_changed)
	sfx_slider.value_changed.connect(volume_sfx_changed)
	
	difficulty_slider.value = Global.difficulty
	volume_slider.value = AudioManager.volume_master
	music_slider.value = AudioManager.volume_music
	sfx_slider.value = AudioManager.volume_sfx

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		on_pressed_pause()
		
func on_pressed_pause() -> void:
	if Global.paused == true:
		AudioManager.play(preload("res://Assets/Audio/JDSherbert/Popup Close.wav"))
		menu_pause.hide()
	else:
		AudioManager.play(preload("res://Assets/Audio/JDSherbert/Popup Open.wav"))
		menu_pause.show()
	pause.emit()
	
func difficulty_changed(value: float) -> void:
	Global.difficulty = value
	
func volume_master_changed(value: float) -> void:
	AudioManager.set_master_volume(value)
	Global.main_menu.get_node("%VolumeSlider").value = AudioManager.volume_master

func volume_music_changed(value: float) -> void:
	AudioManager.set_music_volume(value)
	Global.main_menu.get_node("%MusicSlider").value = AudioManager.volume_music

func volume_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)
	Global.main_menu.get_node("%SFXSlider").value = AudioManager.volume_sfx

func look_at_interpolated(t_pos : Vector2, weight : float = 0.1):
	sprite.rotation = lerpf(sprite.rotation, sprite.rotation + sprite.get_angle_to(t_pos) - (PI*0.5), weight)
	
#-----------------------------------#
#----------DAMAGE HANDLING----------#
#-----------------------------------#

func take_damage(incoming_damage: float) -> bool:
	print("player told to take damage")
	if immune == true:
		print("player found to be immune")
		return false
	AudioManager.play(preload("res://Assets/Audio/VOiD1/Hit_2.wav"))
	if incoming_damage >= hp:
		hp = 0
		bar_health.value = 0
		alive = false
		player_died.emit()
		return true
	hp -= incoming_damage
	bar_health.value = (hp / max_hp) * 100
	immune = true
	sprite_art.damage_flash()
	return true

func on_damage_flash_end() -> void:
	immune = false
	
func on_press_next_turn() -> void:
	Global.on_press_next_turn()
	

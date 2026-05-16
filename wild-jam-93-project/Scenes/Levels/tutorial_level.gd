extends Node2D

@export var max_x = 4000
@export var min_x = -500
@export var max_y = 1000
@export var min_y = -1000

@export var music: AudioManager.Music = AudioManager.Music.NOVA

@onready var background: Polygon2D = %Background
@onready var exit_gate: Area2D = %ExitGate

@onready var leave_menu: PanelContainer = %LeaveMenu
@onready var button_leave_tutorial: Button = %ButtonLeaveTutorial
@onready var button_keep_playing_tutorial: Button = %ButtonKeepPlayingTutorial


const SHIP = preload("res://Scenes/player_ship.tscn")
const ASTEROID = preload("res://Scenes/Interactables/asteroid.tscn")
const ENEMY_SHIP = preload("res://Scenes/Interactables/enemy_ship.tscn")
const FREIGHTER = preload("res://Scenes/Interactables/enemy_freighter.tscn")
const SPINNER = preload("res://Scenes/Interactables/spinner.tscn")
const SNIPER = preload("res://Scenes/Interactables/cyber_sniper.tscn")
const SPICE = preload("res://Scenes/Interactables/spice.tscn")

const TUTORIAL_SPICE = preload("res://Scenes/Levels/Tutorial/tutorial_spice.tscn")
const TUTORIAL_CIVILIAN = preload("res://Scenes/Levels/Tutorial/tutorial_civilian_ship.tscn")
const TUTORIAL_ENEMY = preload("res://Scenes/Levels/Tutorial/tutorial_enemy_ship.tscn")


var player_ship: Node2D = null



#TUTORIAL SLIDES
@onready var tutorial_slide: PanelContainer = %TutorialSlide
@onready var label_tutorial_title: Label = %LabelTutorialTitle
@onready var label_tutorial_text: Label = %LabelTutorialText
@onready var button_okay: Button = %ButtonOkay

var considering_exit: bool = false
var tutorial_step: int = 0
var spawned_spice: bool = false
var spawned_cargo: bool = false
var spawned_enemy: bool = false

# TUTORIAL STEPS
#--- 0 = Tutorial started
#--- 1 = Player read welcome
#--- 2 = Player read how to move
#--- 3 = Player moved
#--- 4 = Player read how to end turn
#--- 5 = Player ended turn
#--- 6 = New turn started
#--- 7 = Player read what is spice
#--- 8 = Player collected the spice
#--- 9 = Player read what is cargo ship
#--- 10 = Player read what is attack
#--- 11 = Player killed cargo_ship
#--- 12 = Player read what is bounty
#--- 13 = Player killed enemy ship
#--- 14 = Player read what is warp gate

func _ready() -> void:
	player_ship = SHIP.instantiate()
	player_ship.position = Vector2.ZERO 
	add_child(player_ship)
	
	player_ship.camera.limit_left = min_x
	player_ship.camera.limit_right = max_x
	player_ship.camera.limit_top = min_y
	player_ship.camera.limit_bottom = max_y
	
	var p_tl = Vector2(min_x + 20, max_y - 20)
	var p_tr = Vector2(max_x - 20, max_y - 20)
	var p_br = Vector2(max_x - 20, min_y + 20)
	var p_bl = Vector2(min_x + 20, min_y + 20)
	
	var p_arr = PackedVector2Array([p_tl, p_tr, p_br, p_bl])
	
	background.polygon = p_arr
	
	AudioManager.play_music(music)
	
	#SIGNALS
	Global.turn_started.connect(on_new_turn)
	button_leave_tutorial.pressed.connect(on_press_leave_tutorial)
	button_keep_playing_tutorial.pressed.connect(on_press_keep_playing)
	exit_gate.player_tried_exit.connect(on_player_exit)
	player_ship.pause.connect(on_press_pause)
	button_okay.pressed.connect(hide_tutorial_prompt)
	
	Global.paused = false

func _process(delta: float) -> void:
	print("Current tutorial step: ", tutorial_step)
	if tutorial_step == 0:
		show_tutorial_prompt("Welcome to Star Bounty", "You are a not-so notorious Space Pirate, hungry for spice - the quickest way to a tidy profit.
		Each turn in Star Bounty lasts 3 seconds. You and your enemies will plot your orders, then watch as the ships play out their actions.
		It's a game of strategy, take your time, pay attention to the enemies and gather as much spice as you can before leaving.
		Good luck!")
	if tutorial_step == 1:
		show_tutorial_prompt("How to Move", "To acheive anything, you'll have learn how to move your ship.
		After closing this dialogue box, click the 'Move' order on the right - or press the M key.
		Then, hover your mouse where you'd like to move, and left-click to 'plot' the order.")
	if tutorial_step == 3:
		show_tutorial_prompt("Ending Your Turn", "Great, you've successfully plotted a move order, but this does nothing on it's own.
		You now need to end your turn. You can do so by pressing the End Turn button over to the right, or by pressing space.
		Afterwards, you'll get to watch youre ship fly through space. If you didn't use all of your fuel for this turn, the ship will simply hold it's position after it's done moving.")
	if tutorial_step == 6:
		show_tutorial_prompt("Spice spotted!", "Lucky you, some spice has drifted into this region of space.
		Spice is a valuable resource, everyone wants it, it's easy to transport, basically, it's cash! Time to get rich...
		Order your ship to fly over the spice in order to collect it.")
	if tutorial_step == 7 and spawned_spice == false:
		print("Spawning spice")
		spawned_spice = true
		var spawn_point = player_ship.position + (Vector2.RIGHT * 450)
		var new_spice = TUTORIAL_SPICE.instantiate()
		new_spice.position = spawn_point
		add_child(new_spice)
	if tutorial_step == 8:
		show_tutorial_prompt("Civilian spotted!", "Spice is hard to come by and space is big, you're not going to find much just floating by like that.
		Fortunately, some 'honest' folk spend their days 'participating' in the 'economy' by 'working hard' and expect to get paid 'their spice', which they load onto 'their cargo ships'.
		One such cargo ship has just crossed your path. You'll have to predict where it's moving, and shoot it out with your lasers if you want  'it's spice' (YOUR SPICE!)")
	if tutorial_step == 9:
		show_tutorial_prompt("Firing your lasers", "Wondering how to fire at the cargo ship, huh? We'll add an attack button over to the right, you can press that or press the A key to start plotting an attack.
		Just like moving, simply point your mouse where you'd like the attack to go, then left click.
		Be mindful though, shooting also costs fuel. That means you're always deciding how much you want to move each turn, vs how many times you'd like to shoot. Now take out that cargo ship!")
	if tutorial_step == 10 and spawned_cargo == false:
		spawned_cargo = true
		var spawn_point = player_ship.position + (Vector2.RIGHT * 450)
		var new_cargo = TUTORIAL_CIVILIAN.instantiate()
		new_cargo.position = spawn_point
		add_child(new_cargo)
		new_cargo.plot_orders()
	if tutorial_step == 11:
		show_tutorial_prompt("Not-so-not-so Notorious", "Nicely done, I hope you were close enough to hoover up that spice! Unfortunately, some folks don't take kindly to being blown to smithereens.
		If you take a look at the top left, you'll see that destroying that 'civilian' has raised your bounty! That means you're cooler, for sure, but it also means the navy will be coming after you soon.
		The higher your bounty, the more enemy ships will come for you. In fact, here's a navy vessel now! See if you can best it in combat... make sure to move away from those fire lines!")
	if tutorial_step == 12 and spawned_enemy == false:
		spawned_enemy = true
		var spawn_point = player_ship.position + (Vector2.LEFT * 600)
		var new_enemy = TUTORIAL_ENEMY.instantiate()
		new_enemy.position = spawn_point
		add_child(new_enemy)
		new_enemy.plot_orders()
	if tutorial_step == 13:
		show_tutorial_prompt("The get-away", "Well you're a true warrior of the stars now. Luckily that was just a scout, it looks like this sector is clear.
		During normal play, more and more enemies will come as your bounty rises, eventually overwhelming you. The only way out is to use a warp gate - like the one you came in on.
		Fly far to the right, and you'll find an exit gate - you can tell by it's green warp-field. Fly into the field and you'll be able to escape, good luck!")


func on_player_exit() -> void:
	if tutorial_step < 14:
		return
	considering_exit = true
	leave_menu.show()
	player_ship.menu_pause.hide()
	Global.paused = true
	
func on_press_leave_tutorial() -> void:
	AudioManager.stop_all_looping()
	Global.pressed_main_menu()
	
func on_press_keep_playing() -> void:
	considering_exit = false
	leave_menu.hide()
	Global.paused = false

func on_new_turn() -> void:
	return
		
func spawn_enemy(enemy_to_spawn) -> void:
	var new_enemy = enemy_to_spawn.instantiate()
	new_enemy.position.x = randf_range(min_x, max_x)
	new_enemy.position.y = randf_range(min_y, max_y)
	new_enemy.position = force_to_edge(new_enemy.position)
	add_child(new_enemy)
	new_enemy.add_to_group("enemies")
	new_enemy.plot_orders()

func force_to_edge(v: Vector2) -> Vector2:
	var edge_roll = randi_range(1, 4)
	if edge_roll == 1: v.x = min_x
	if edge_roll == 2: v.x = max_x
	if edge_roll == 3: v.x = min_y
	if edge_roll == 4: v.x = max_y
	return v
	
func on_press_pause() -> void:
	if considering_exit == true:
		return
	Global.on_press_pause()
	
func show_tutorial_prompt(title: String = "No Title", text: String = "No text") -> void:
	label_tutorial_title.text = title
	label_tutorial_text.text = text
	tutorial_slide.show()

func hide_tutorial_prompt() -> void:
	tutorial_slide.hide()
	tutorial_step += 1

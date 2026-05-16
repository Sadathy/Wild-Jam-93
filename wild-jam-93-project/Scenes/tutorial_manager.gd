extends Node

var level: Node
var tutorial_step: int
var player_ship: CharacterBody2D
var in_tutorial: bool = false

@onready var button_move: Button = %ButtonMove
@onready var button_end_turn: Button = %ButtonEndTurn
@onready var button_attack: Button = %ButtonAttack

func _ready() -> void:
	if !("tutorial_step" in Global.level):
		return
	in_tutorial = true
	level = Global.level
	player_ship = get_parent()

func _process(_delta: float) -> void:
	if in_tutorial == false:
		return
	# Do tutorial interferance with player functionality
	tutorial_step = level.tutorial_step
	# TUTORIAL STEPS
	#--- 0 = Tutorial started
	#--- The tutorial level will display a prompt
	#--- 1 = Player read welcome
	#--- The tutorial level will display a prompt
	#--- 2 = Player read how to move
	#--- Now we should allow the player to move
	if tutorial_step < 2: button_move.hide()
	else: button_move.show()
	#--- Also went into state_no_plot and blocked moving
	#--- 3 = Player moved
	#--- The tutorial level will display a prompt
	#--- 4 = Player read how to end turn
	#--- Now we should allow the player to end turn
	if tutorial_step < 4: button_end_turn.hide()
	else: button_end_turn.show()
	#--- Also went into player_ship and blocked turn ending. Also made it increment tutorial step
	#--- 5 = Player ended turn
	#--- Nothing will happen except tutorial step increments
	#--- Went into super_state_executing and made it incriment step
	#--- 6 = New turn started
	#--- The tutorial level will display a prompt
	#--- 7 = Player read what is spice
	#--- Went into tutorial level and made it spawn a spice
	#--- 8 = Player collected the spice
	#--- Tutorial level should display a prompt here
	#--- 9 = Player read what is cargo ship
	#--- Tutorial level should display a prompt here
	#--- 10 = Player read what is attack
	#--- Go in and enable attacking here
	if tutorial_step < 10: button_attack.hide()
	else: button_attack.show()
	#--- Tutorial level spawns the tutorial cargo ship
	#--- 11 = Player killed cargo_ship
	#--- Tutorial levle should show a prompt here
	#--- 12 = Player read what is bounty
	#--- 13 = Player killed enemy ship
	#--- 14 = Player read what is warp gate

extends PanelContainer

#------------------------------#
#-----////MENU SCREENS////-----#
#------------------------------#
@onready var main: PanelContainer = %Main
@onready var credits: PanelContainer = %Credits
@onready var options: PanelContainer = %Options

#------------------------------#
#-----////MENU BUTTONS////-----#
#------------------------------#
@onready var button_start: Button = %ButtonStart
@onready var button_options: Button = %ButtonOptions
@onready var button_credits: Button = %ButtonCredits
@onready var button_quit: Button = %ButtonQuit
@onready var button_return: Button = %ButtonReturn
@onready var button_tutorial: Button = %ButtonTutorial


func _ready() -> void:
	# Set up signals for buttons
	button_start.pressed.connect(start_pressed)
	button_options.pressed.connect(options_pressed)
	button_credits.pressed.connect(credits_pressed)
	button_quit.pressed.connect(quit_pressed)
	button_return.pressed.connect(return_pressed)
	button_tutorial.pressed.connect(tutorial_pressed)
	
	Global.main_menu = self
	
func start_pressed() -> void:
	AudioManager.play(preload("res://Assets/Audio/obsydianx/confirm_style_2_003.wav"))
	Global.new_level(Global.LEVEL_GENERIC)
	hide()
	
func tutorial_pressed() -> void:
	AudioManager.play(preload("res://Assets/Audio/obsydianx/confirm_style_2_003.wav"))
	Global.new_level(Global.LEVEL_TUTORIAL)
	hide()
	
func options_pressed() -> void:
	AudioManager.play(preload("res://Assets/Audio/obsydianx/confirm_style_2_003.wav"))
	button_return.show()
	options.show()
	hide()
	
func credits_pressed() -> void:
	AudioManager.play(preload("res://Assets/Audio/obsydianx/confirm_style_2_003.wav"))
	button_return.show()
	credits.show()
	hide()
	
func quit_pressed() -> void:
	get_tree().quit()
	
func return_pressed() -> void:
	AudioManager.play(preload("res://Assets/Audio/obsydianx/back_style_2_001.wav"))
	button_return.hide()
	options.hide()
	credits.hide()
	show()

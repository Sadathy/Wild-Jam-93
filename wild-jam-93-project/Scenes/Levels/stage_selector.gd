extends Node2D

@onready var sprite: Sprite2D = %Sprite
@onready var label_type: Label = %LabelType
@onready var label_details: Label = %LabelDetails

@onready var mouse_detector: Area2D = %MouseDetector
@onready var hover_show: Polygon2D = %HoverShow
@onready var tooltip: PanelContainer = %Tooltip

var id: int = -1
var display_name: String = ""
var details: String = ""

signal stage_clicked

func _ready() -> void:
	if id == 0:
		return
	label_type.text = display_name
	label_details.text = details
	
	mouse_detector.mouse_entered.connect(on_mouse_enter)
	mouse_detector.mouse_exited.connect(on_mouse_exit)
	mouse_detector.input_event.connect(on_clicked)
	
func on_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Player clicked stage ID: ", id)
		stage_clicked.emit(id)

func on_mouse_enter() -> void:
	AudioManager.play(preload("res://Assets/Audio/obsydianx/cursor_style_2.wav"))
	hover_show.desired_alpha = 0.4
	tooltip.desired_alpha = 1.0
	tooltip.show()
	
func on_mouse_exit() -> void:
	hover_show.desired_alpha = 0
	tooltip.desired_alpha = 0
	tooltip.hide()

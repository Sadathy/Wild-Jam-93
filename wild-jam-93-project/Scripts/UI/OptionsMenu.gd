extends PanelContainer

@onready var difficulty_slider: HSlider = %DifficultySlider
@onready var volume_slider: HSlider = %VolumeSlider

func _ready() -> void:
	# Set up signals for sliders
	difficulty_slider.drag_ended.connect(difficulty_changed)
	volume_slider.drag_ended.connect(volume_changed)
	
	difficulty_slider.value = Global.difficulty
	volume_slider.value = Global.volume
	
func difficulty_changed() -> void:
	Global.difficulty = difficulty_slider.value
	
func volume_changed() -> void:
	Global.volume = volume_slider.value

extends PanelContainer

@onready var difficulty_slider: HSlider = %DifficultySlider
@onready var volume_slider: HSlider = %VolumeSlider

func _ready() -> void:
	# Set up signals for sliders
	difficulty_slider.drag_ended.connect(difficulty_changed)
	volume_slider.value_changed.connect(volume_changed)
	
	difficulty_slider.value = Global.difficulty
	volume_slider.value = AudioManager.volume_master
	
func difficulty_changed(value: float) -> void:
	Global.difficulty = value
	
func volume_changed(value: float) -> void:
	AudioManager.set_master_volume(value)

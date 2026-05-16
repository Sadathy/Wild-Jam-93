extends PanelContainer

@onready var difficulty_slider: HSlider = %DifficultySlider
@onready var volume_slider: HSlider = %VolumeSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider

func _ready() -> void:
	# Set up signals for sliders
	difficulty_slider.drag_ended.connect(difficulty_changed)
	volume_slider.value_changed.connect(volume_master_changed)
	music_slider.value_changed.connect(volume_music_changed)
	music_slider.value_changed.connect(volume_sfx_changed)
	
	difficulty_slider.value = Global.difficulty
	volume_slider.value = AudioManager.volume_master
	music_slider.value = AudioManager.volume_music
	sfx_slider.value = AudioManager.volume_sfx
	
func difficulty_changed(value: float) -> void:
	Global.difficulty = value
	
func volume_master_changed(value: float) -> void:
	AudioManager.set_master_volume(value)

func volume_music_changed(value: float) -> void:
	AudioManager.set_music_volume(value)

func volume_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)

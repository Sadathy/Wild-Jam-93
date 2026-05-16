extends Sprite2D

var flashing: bool = false
var white: bool = false

const DEFAULT_FLASH_TIME: float = 0.5
const DEFAULT_FLASH_INTERVAL: float = 0.1
const DEFAULT_FLASH_FREQUENCY: float = 5

var flash_timer: float = 0
var interval_timer: float = 0
var frequency_timer: float = 0

func _ready() -> void:
	material.set_shader_parameter("white", true)

func _process(delta: float) -> void:
	frequency_timer -= delta
	if frequency_timer < 0:
		frequency_timer += DEFAULT_FLASH_FREQUENCY
		flashing = true
		white = true
		material.set_shader_parameter("flashing", white)
		flash_timer = DEFAULT_FLASH_TIME
		frequency_timer = DEFAULT_FLASH_FREQUENCY
	if flashing == false:
		return

	flash_timer -= delta
	interval_timer -= delta
	
	if interval_timer <= 0:
		interval_timer = DEFAULT_FLASH_INTERVAL
		white = !white
		material.set_shader_parameter("flashing", white)
		
	if flash_timer <= 0:
		flashing = false
		material.set_shader_parameter("flashing", false)

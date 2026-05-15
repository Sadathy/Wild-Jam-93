extends Sprite2D

signal finished
signal started

var flashing: bool = false
var white: bool = false

const DEFAULT_FLASH_TIME: float = 0.5
const DEFAULT_FLASH_INTERVAL: float = 0.1

var flash_timer: float = 0
var interval_timer: float = 0

func damage_flash() -> void:
	flashing = true
	material.set_shader_parameter("flashing", flashing)
	white = true
	material.set_shader_parameter("white", white)
	flash_timer = DEFAULT_FLASH_TIME
	interval_timer = DEFAULT_FLASH_INTERVAL
	started.emit()

func _process(delta: float) -> void:
	if flashing == false:
		return
	flash_timer -= delta
	interval_timer -= delta
	
	if interval_timer <= 0:
		interval_timer = DEFAULT_FLASH_INTERVAL
		white = !white
		material.set_shader_parameter("white", white)
	
	if flash_timer <= 0:
		flashing = !flashing
		material.set_shader_parameter("flashing", flashing)
		finished.emit()

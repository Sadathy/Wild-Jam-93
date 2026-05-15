extends Sprite2D

var lifespan: float = 1
var lifetime: float = 0

func _process(delta: float) -> void:
	lifetime += delta
	if lifetime > lifespan: queue_free()
	modulate = Color(1, 1, 1, 1 - (lifetime / lifespan))
	var scale_factor = 1 + (3 * (lifetime / lifespan))
	scale = Vector2(scale_factor, scale_factor)
	

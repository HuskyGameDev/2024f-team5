extends ParallaxBackground

@export var speed: float = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll_base_offset -= Vector2(100, 0) * delta * speed

extends ParallaxBackground

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll_base_offset -= Vector2(100, 0) * delta

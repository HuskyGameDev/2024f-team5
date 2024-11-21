extends GPUParticles2D

@onready var long_smoke: GPUParticles2D = $LongSmoke

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emitting = true
	long_smoke.emitting = true

func _on_long_smoke_finished() -> void:
	queue_free()

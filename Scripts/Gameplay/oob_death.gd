extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.frame = 0
	$GPUParticles2D.emitting = true
	await $GPUParticles2D.finished
	queue_free()

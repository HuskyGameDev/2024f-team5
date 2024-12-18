extends Node
## Logic for the banana peel game object.
## Jay Hawkins

@export var stun_length: float = 1.5

@export_category("Lifecycle timers")
## The amount of time from spawning before the item can be picked up
@export var grace: float = 1.25
## The amount of time after grace before the item begins to despawn
@export var lifetime: float = 15

@onready var trigger: Area2D = $Trigger
@onready var anim: AnimationPlayer = $AnimationPlayer

## Goes through item's lifecycle then despawns
func _lifecycle() -> void:
	# Grace period - item can't be activated
	trigger.monitoring = false
	anim.play("grace period")
	await get_tree().create_timer(grace).timeout
	# Can now pick item up
	trigger.monitoring = true
	anim.play("lifetime")
	await get_tree().create_timer(lifetime).timeout
	# Begin fading out
	anim.play("despawn")
	# The animation is slightly longer than the length of the fadeout.
	# This gives the player a bit of lenience to when they can pick the item up.
	await get_tree().create_timer(anim.current_animation_length).timeout
	queue_free()

func _ready() -> void:
	_lifecycle()

func _on_trigger_body_entered(body: Node2D) -> void:
	if(body is Player):
		body.stun(stun_length)
		queue_free()

extends Area2D
class_name ItemPickup
## Trigger that picks up gun or other item in future
## Jay Hawkins
@export var gun: PackedScene

# Gives gun to player and deletes self
func _on_body_entered(body: CharacterBody2D) -> void:
	if body is Player:
		var node: Node = gun.instantiate()
		body.equip(node)
		queue_free()

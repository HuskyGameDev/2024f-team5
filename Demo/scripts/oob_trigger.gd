extends Area2D
class_name Hazard
## Is a trigger (Area2D) that kills player upon entering.

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# The rotation aspect of the oob death doesn't currently work
		# It will always face up
		body.die(true, rotation)

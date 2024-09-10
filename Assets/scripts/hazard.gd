extends Area2D
class_name Hazard
## Is a trigger (Area2D) that kills player upon entering.

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()

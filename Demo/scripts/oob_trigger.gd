extends Area2D
class_name Hazard
## Is a trigger (Area2D) that kills player upon entering.

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# Goop chunks will always shoot toward the center of world borders
		var theta: float = get_angle_to(body.global_position) - PI/2
		body.call_deferred("die", true, theta)

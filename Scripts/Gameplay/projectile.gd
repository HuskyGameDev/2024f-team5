extends Node

# Amount that the projectile effects the grip of the player
@export var damage: float = 30
# Amount of knockback that player recieves on collision
@export var knockback: float = 20
@export var delete_on_collide: bool = true

func _on_body_entered(body: Node) -> void:
	if(delete_on_collide):
		queue_free()

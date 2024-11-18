extends Area2D
class_name ItemPickup
## Trigger that picks up gun or other item in future
## Jay Hawkins
@export var gun: PackedScene
@export var gun_resource: GunResource
@export var effect: PackedScene

@onready var icon_display: Sprite2D = $Icon
var cur_effect: Node2D

func _ready() -> void:
	icon_display.texture = gun_resource.icon
	cur_effect = effect.instantiate()
	cur_effect.position = self.position

# Gives gun to player and deletes self
func _on_body_entered(body: CharacterBody2D) -> void:
	if body is Player:
		var node: Node = gun.instantiate()
		node.name = body.name
		node.gun_resource = gun_resource
		body.rpc("equip", node)
		queue_free()

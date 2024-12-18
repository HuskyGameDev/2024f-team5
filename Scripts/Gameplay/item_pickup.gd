extends Area2D
class_name ItemPickup
## Trigger that picks up an item via spawner
## Jay Hawkins
@export var gun: PackedScene
@export var gun_resource: GunResource

@onready var icon_display: Sprite2D = $Icon

## Control bool to prevent multiple players picking up the same weapon on
## The same frame
var _picked_up: bool = false

func _ready() -> void:
	icon_display.texture = gun_resource.icon

# Gives gun to player and deletes self
func _on_body_entered(body: CharacterBody2D) -> void:
	if body is Player && !_picked_up:
		body.call_deferred("equip", gun, gun_resource)
		_picked_up = true
		queue_free()

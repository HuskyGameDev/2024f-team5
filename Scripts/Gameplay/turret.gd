extends Node
class_name Turret

@onready var timer: Timer = $Timer

## Time between shooting bullets
@export var period: float = 1
@export var gun_resource: GunResource
@export var gun_scene: PackedScene
@export var aim_at: float = 0

var _equipped_item: Node

func equip(scene: PackedScene = gun_scene, gun_resource: GunResource = gun_resource) -> void:
	var item: Gun = scene.instantiate()
	item.gun_resource = gun_resource
	item.resourcePath = gun_resource.resource_path
	item.name = name
	item.gun_resource = gun_resource
	_equipped_item = item
	add_child(item)
	if(aim_at > PI / 2):
		$Sprite2D.flip_h = true
	item.rotation = aim_at
	item.infinite_ammo = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	equip()
	timer.wait_time = period
	timer.start()

func _on_timer_timeout() -> void:
	_equipped_item._shoot(Vector2(0, 0), true)
	timer.start()

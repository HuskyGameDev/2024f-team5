extends RigidBody2D
class_name DroppedItem
## Item that is dropped and can be picked up again. Similar to item_pickup.gd
## Jay Hawkins

# KEEP GUN NULL IN dropped_item.tscn! PACKED SCENES CANNOT CIRCULARLY REFERENCE
# EACH OTHER. ASSIGN UPON DROP
@export var gun: PackedScene
@export var gun_resource: GunResource 
## Amount of ammo left in gun. Should be set externally upon drop.
@export var ammo: int = 0
## The velocity that the gun should always try to move at.
## By default falls slowly.
@export var natVel: Vector2 = Vector2(0, 10)
## The rate that the object will step toward natVel per second.
@export var accel: float = 10

@export_category("Lifecycle timers")
## The amount of time from spawning before the item can be picked up
@export var grace: float = 1.25
## The amount of time after grace before the item begins to despawn
@export var lifetime: float = 15

@onready var spi: Sprite2D = $Sprite2D
@onready var trigger: Area2D = $PickupTrigger
@onready var anim: AnimationPlayer = $AnimationPlayer

## Control bool to prevent multiple players picking up the same weapon on
## The same frame
var _picked_up: bool = false

## Goes through item's lifecycle then despawns
func _lifecycle() -> void:
	# Grace period - item can't be picked up
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# We will use the icon for now as it will help make size more consistent.
	spi.texture = gun_resource.icon
	_lifecycle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	linear_velocity = linear_velocity.move_toward(natVel, accel * delta)

func _on_pickup_trigger_body_entered(body: Node2D) -> void:
	# Item only picks up if player is unarmed
	if body is Player && !_picked_up && body._equipped_item == null:
		body.call_deferred("equip", gun, gun_resource, ammo)
		_picked_up = true
		queue_free()

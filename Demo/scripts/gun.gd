extends Node2D
class_name Gun
## This should probably be a resource or whatever Nolan was talking about
## But idk how to do allat
## Basically this determines basic gun behaviour
## Jay Hawkins

# This value is needed to correct the gun's position when pointing left
const REVERSE_OFFSET = -48
const SHOOT_VELOCITY = 400 

@onready var spi: Sprite2D = $Sprite2D
@onready var snd: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Visuals
@export var smoke: PackedScene
## Barrel is where smoke effects and bullets spawn
# We could keep track of a Vector2 to make it more "optimal" because we're only
# Using the node for it's position, but this method makes it easier to edit.
@export var barrel: Node2D
@export var barrel_pos: Array[Vector2]
## Gun is pointing left if true
var flipped: bool = false
## True if cooldown is complete
var cooldown: bool = true
## Fire rate (inverse of cooldown) in rounds per second
@export var firerate: float = 18

func shoot(mousepos: Vector2) -> void:
	if(!cooldown):
		return
	var par: Node = get_parent()
	var diff: Vector2 = mousepos - self.global_position
	var angle: float = diff.angle() + PI
	var recoil: Vector2 = Vector2(cos(angle), sin(angle)) * SHOOT_VELOCITY
	par.velocity += recoil
	barrel.add_child(smoke.instantiate())
	snd.play()
	# Cooldown handling
	cooldown = false
	await get_tree().create_timer(1 / firerate).timeout
	cooldown = true

func flip() -> void:
	spi.offset.x = REVERSE_OFFSET
	spi.flip_h = true
	flipped = true
	barrel.position = barrel_pos[1]
	barrel.rotate(PI)

func unflip() -> void:
	spi.offset.x = 0
	spi.flip_h = false
	flipped = false
	barrel.rotate(PI)
	barrel.position = barrel_pos[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mousepos: Vector2 = get_global_mouse_position()
	look_at(mousepos)
	if(mousepos.x < global_position.x):
		if(!flipped):
			flip()
	elif(flipped):
		unflip()
	if(flipped):
		rotation += 135
		
	if(Input.is_action_just_pressed("shoot")):
		shoot(mousepos)

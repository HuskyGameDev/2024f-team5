extends Node2D
class_name Gun
## This should probably be a resource or whatever Nolan was talking about
## But idk how to do allat
## Basically this determines basic gun behaviour
## Jay Hawkins
##Minor edits by Thomas Wilkins

const SHOOT_VELOCITY: float = 400 

#Thomas: adding some weight so we can slow players with guns down if they just walk, for now I'm going to say this is in ounces 
const GUN_WEIGHT: float = 30.16

# This value is needed to correct the gun's position when pointing left
@export var rev_offset: float = -48

@onready var spi: Sprite2D = $Sprite2D
@onready var snd: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Visuals
@export var smoke: PackedScene
## Barrel is where smoke effects and bullets spawn
# We could keep track of a Vector2 to make it more "optimal" because we're only
# Using the node for it's position, but this method makes it easier to edit.
@onready var barrel: Node2D = $Sprite2D/Barrel
@export var barrel_pos: Array[Vector2]

# For ADS Line
@onready var line: Line2D = $Sprite2D/Barrel/Line2D
var ads: bool = false

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
	spi.offset.x = rev_offset
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
	
	if(get_global_mouse_position().x < global_position.x):
		if(!flipped):
			flip()
	elif(flipped):
		unflip()
	var crosshairAngle: float = global_position.angle_to_point(get_global_mouse_position())
	# The total y offset of barrel from origin. Needed to correct aim
	var offsetY: float = -barrel.position.y - spi.position.y
	# corrects y offset when flipped
	if(flipped):
		offsetY *= -1
	var mousepos: Vector2 = (
		get_global_mouse_position() + 
		Vector2(offsetY * sin(crosshairAngle + PI), offsetY * cos(crosshairAngle))
		# NO clue why the x value nees PI added to the angle,
		# But it helps correct the angle when it's close to +-90 degrees
	)
	look_at(mousepos)
	
	if(flipped):
		rotation += PI
	
	if(ads):
		line.points[1] = Vector2(1000, 0)
		
	if(Input.is_action_just_pressed("shoot")):
		shoot(mousepos)
	if(Input.is_action_just_pressed("ADS")):
		ads = true
		line.visible = true
	if(Input.is_action_just_released("ADS")):
		ads = false
		line.visible = false

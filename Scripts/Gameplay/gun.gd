## Handles gun controls and shooting
## Jay Hawkins, Thomas Wilkins

extends Node2D
class_name Gun

# Constants and enums
enum WeaponType { BULLET, MELEE, LASER }

# Exported class variables
@export var barrel_pos: Array[Vector2]
## Fire rate (inverse of cooldown) in rounds per second
@export var firerate: float = 18
## Count of rounds in a magazine
# Fun fact: 15 is the number of rounds in a standard glock 19 magazine
@export var max_ammo: int = 15
# This value is needed to correct the gun's position when pointing left
@export var rev_offset: float = -48
@export var smoke: PackedScene
@export var weapon_type: WeaponType
@export var weapon_recoil: float = 400
#Thomas: adding some weight so we can slow players with guns down if they just walk, for now I'm going to say this is in ounces 
#Jay: changed from constant to variable because it should vary between guns
@export var weight: float = 15
## The amount of grip lost each gunshot as a %
@export var grip_loss: float = 30

# Child node references
## Where smoke effects and bullets spawn
@onready var barrel: Node2D = $Sprite2D/Barrel
@onready var line: Line2D = $Sprite2D/Barrel/Line2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var spi: Sprite2D = $Sprite2D
@onready var hurt_sound: AudioStreamPlayer2D = $Shield/DamageSound

# Class variables
var player: Player
## When true, the "laser sight" ADS line is visible
var ads: bool = false
var ammo: int = max_ammo
## True if cooldown is complete
var cooldown: bool = true
## Gun is pointing left if true
var flipped: bool = false
var hud: Hud

# ====================== [ CLASS METHODS ] =====================================

func _flip() -> void:
	spi.offset.x = rev_offset
	spi.flip_h = true
	flipped = true
	barrel.position = barrel_pos[1]
	barrel.rotate(PI)

func _shoot(mousepos: Vector2) -> void:
	if(!cooldown):
		return
	var par: Node = get_parent()
	if(ammo <= 0):
		par.unequip()
		return
	var diff: Vector2 = mousepos - self.global_position
	var angle: float = diff.angle() + PI
	var recoil: Vector2 = Vector2(cos(angle), sin(angle)) * weapon_recoil
	player.grip -= grip_loss
	par.velocity += recoil
	barrel.add_child(smoke.instantiate())
	sound.play()
	# Godot doesn't support ++/-- incrementing. Fuck that.
	ammo -= 1
	hud.ammo_counter.text = "%d/%d" % [ammo, max_ammo]
	# Cooldown handling
	cooldown = false
	await get_tree().create_timer(1 / firerate).timeout
	cooldown = true

func _unflip() -> void:
	spi.offset.x = 0
	spi.flip_h = false
	flipped = false
	barrel.rotate(PI)
	barrel.position = barrel_pos[0]

# ============================= [ SIGNALS ] ====================================

func _process(_delta: float) -> void:
	if(get_global_mouse_position().x < global_position.x):
		if(!flipped):
			_flip()
	elif(flipped):
		_unflip()
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
		_shoot(mousepos)
	if(Input.is_action_just_pressed("ADS")):
		ads = true
		line.visible = true
	if(Input.is_action_just_released("ADS")):
		ads = false
		line.visible = false

func _on_shield_body_entered(body: Node2D) -> void:
	var angle: float = global_position.angle_to_point(body.position)
	print(angle)
	player.grip -= 20
	hurt_sound.play()
	pass # Replace with function body.

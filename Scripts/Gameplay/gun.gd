## Handles gun controls and shooting
## Jay Hawkins, Thomas Wilkins

extends Node2D
class_name Gun

# Constants and enums
enum WeaponType { BULLET, MELEE, LASER }

# For testing with number keys
@export var gun1 : GunResource
@export var gun2 : GunResource
@export var gun3 : GunResource

# For normal gameplay
@export var gun_resource: GunResource

# Exported class variables
## Fire rate (inverse of cooldown) in rounds per second
var firerate: float
## Count of rounds in a magazine
# Fun fact: 15 is the number of rounds in a standard glock 19 magazine
var max_ammo: int

var smoke: PackedScene
@export var weapon_type: WeaponType #TODO: make this take from activeGunResource
var weapon_recoil: float
#Thomas: adding some weight so we can slow players with guns down if they just walk, for now I'm going to say this is in ounces 
#Jay: changed from constant to variable because it should vary between guns
var weight: float
## The amount of grip lost each gunshot as a %
var grip_loss: float
## The type of projectile that the gun will shoot
var projectile: PackedScene
var proj_speed: float
## Extra distance given to the bullet from barrel
var exit_padding: float
## Can trigger be held to continuously fire weapon.
@export var full_auto: bool = false #TODO: I feel like this should always be true (was false previously)
# ^ fair take but I feel like since we're mostly dealing with pistols,
# this option will give more variety to weapon feel.

# Child node references
## Where smoke effects and bullets spawn
@onready var anim_timer : Timer = $AnimationTimer
@onready var barrel: Node2D = $Sprite2D/Barrel
@onready var line: Line2D = $Sprite2D/Barrel/Line2D
@onready var shield: Area2D = $Shield
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var spi: Sprite2D = $Sprite2D
@onready var hurt_sound: AudioStreamPlayer2D = $Shield/DamageSound
# This value is needed to correct the gun's position when pointing left
@onready var rev_offset: float = -2 * spi.position.x
# Needed for flipping the barrel with gun
@onready var init_barrel_posX: float = barrel.position.x
@onready var rev_barrel_posX: float = -init_barrel_posX + rev_offset

# Class variables
var player: Player
## When true, the "laser sight" ADS line is visible
var ads: bool = false
var ammo: int = 0 #was set as ammo: int = max_ammo originally but now max_ammo doesn't get loaded until the ready function is called
## True if cooldown is complete
var cooldown: bool = true
## Gun is pointing left if true
var flipped: bool = false
var hud: Hud

# ====================== [ CLASS METHODS ] =====================================

func _flip() -> void:
	spi.offset.x = rev_offset
	shield.position.x = rev_offset
	spi.flip_h = true
	flipped = true
	#barrel.position = barrel_pos[1]
	barrel.rotate(PI)
	barrel.position.x = rev_barrel_posX

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
	player.projectileMovement = true #Thomas: tell the player movement script to temporarily disable the normal movement so we can fling the character
	player.projectileMoveOffset = recoil.x #If we want to allow players to keep their movement augment the speed by this to allow the player to move in the same direction as the gun? TODO: this isn't functional rn
	par.velocity += recoil
	barrel.add_child(smoke.instantiate())
	sound.play()
	# Godot doesn't support ++/-- incrementing. Fuck that.
	ammo -= 1
	hud.ammo_counter.text = "%d/%d" % [ammo, max_ammo]
	
	# Shoot the actual bullet
	var bullet: Node = projectile.instantiate()
	# If melee, "projectile" will be attached to barrel, otherwise outside
	var melee: bool = false
	if("melee" in bullet && bullet.melee):
		melee = true
		add_child(bullet)
	bullet.global_position = barrel.global_position
	bullet.global_rotation = self.global_rotation
	if "shot_by" in bullet:
		bullet.shot_by = self
	var padding: Vector2 = (Vector2(cos(global_rotation), sin(global_rotation))
		* exit_padding)
	if(flipped):
		bullet.global_rotation += PI
		padding *= -1
	bullet.global_position += padding
	bullet.linear_velocity = (proj_speed * 
	  Vector2(cos(global_rotation), sin(global_rotation)))
	if(flipped):
		bullet.linear_velocity *= -1
	if(!melee):
		get_tree().get_root().add_child(bullet)
	
	# Handle animation
	# Currently only implemented pulse
	if(gun_resource.animation_mode == GunResource.AnimationMode.PULSE):
		spi.texture = gun_resource.alt_sprites[0]
		anim_timer.start()
	elif(gun_resource.animation_mode == GunResource.AnimationMode.PULSE_EMPTY):
		spi.texture = gun_resource.alt_sprites[0]
		if(ammo > 0):
			anim_timer.start()
	
	# Cooldown handling
	cooldown = false
	await get_tree().create_timer(1 / firerate).timeout
	cooldown = true

func _unflip() -> void:
	spi.offset.x = 0
	shield.position.x = 0
	spi.flip_h = false
	flipped = false
	barrel.rotate(PI)
	barrel.position.x = init_barrel_posX


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
	)
	look_at(mousepos)
	
	if(flipped):
		rotation += PI
	
	if(ads):
		line.points[1] = Vector2(1000, 0)
		
	if(full_auto):
		if(Input.is_action_pressed("shoot")):
			_shoot(mousepos)
	else:
		if(Input.is_action_just_pressed("shoot")):
			_shoot(mousepos)
	if(Input.is_action_just_pressed("ADS")):
		ads = true
		line.visible = true
	if(Input.is_action_just_released("ADS")):
		ads = false
		line.visible = false
		
	if(Input.is_key_pressed(KEY_1)):
		load_weapon(gun1)
	if(Input.is_key_pressed(KEY_2)):
		load_weapon(gun2)
	if(Input.is_key_pressed(KEY_3)):
		load_weapon(gun3)

func _on_shield_body_entered(body: Node2D) -> void:
	if "shot_by" in body && body.shot_by == self:
		return
	var angle: float = global_position.angle_to_point(body.position)
	player.grip -= 20
	hurt_sound.play()
	
	#This will load a new weapon for the player TODO: make it take a GunResource for a parameter
func load_weapon(newWeaponResource : GunResource) -> void:
	gun_resource = newWeaponResource
	## Fire rate (inverse of cooldown) in rounds per second
	firerate = newWeaponResource.fireRate
	## Count of rounds in a magazine
	# Fun fact: 15 is the number of rounds in a standard glock 19 magazine
	ammo = newWeaponResource.maxAmmo
	max_ammo = newWeaponResource.maxAmmo
	smoke = newWeaponResource.smoke
	weapon_recoil = newWeaponResource.weaponRecoil
	#Thomas: adding some weight so we can slow players with guns down if they just walk, for now I'm going to say this is in ounces 
	#Jay: changed from constant to variable because it should vary between guns
	weight = newWeaponResource.weaponWeight
	## The amount of grip lost each gunshot as a %
	grip_loss = newWeaponResource.gripLoss
	## The type of projectile that the gun will shoot
	projectile = newWeaponResource.bullet
	proj_speed = newWeaponResource.projectileSpeed
	## Extra distance given to the bullet from barrel
	exit_padding = newWeaponResource.exitPadding
	full_auto = newWeaponResource.full_auto
	
	#Change the gun sprite
	spi.texture = newWeaponResource.weaponSprite
	anim_timer.wait_time = newWeaponResource.pulse_time
	# Currently doesn't implement varied shooting sounds
	sound.stream = newWeaponResource.fireSounds[0]
	barrel.position = newWeaponResource.barrel_pos
	init_barrel_posX = barrel.position.x
	rev_barrel_posX = -init_barrel_posX + rev_offset
	#update ammo count on the HUD
	hud.ammo_counter.text = "%d/%d" % [ammo, max_ammo]

func _ready() -> void:
	load_weapon(gun_resource)

func _on_animation_timer_timeout() -> void:
	spi.texture = gun_resource.weaponSprite

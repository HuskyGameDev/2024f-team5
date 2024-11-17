extends Resource
class_name GunResource

#The goal is to have resources made for each gun that can be loaded into the normal gun script to set all the variables as needed
#Then we can quickly switch between guns and any edits can be made across all of them (since a change to the gun script will affect how these variables are handled)

#Sprites
@export_category("Sprites and Animations")
@export var weaponSprite : Texture2D
@export var alt_sprites: Array[Texture2D]
enum AnimationMode {NONE, PULSE, NEXT, PULSE_EMPTY}
@export var animation_mode : AnimationMode
## The amount of time it takes to return to original sprite when using pulse animation
@export var pulse_time : float = .25
## This is the sprite that should show up on the spawner's display.
@export var icon: Texture2D
@export var bullet: PackedScene
@export var smoke: PackedScene
@export var barrel_pos: Vector2

#Bullet information (if its a melee weapon ignore the rest)
@export_category("Damage Settings")
@export var WeaponType : WeaponReferences.WeaponType

#TODO: need to properly implement this (edit bullet scene?) do we want to construct bullets here or have that as a seperate resource?
@export var weaponDamage : float
@export var weaponKnockback : float 
@export var deleteOnCollide : bool
@export var trailPeriod : float
@export var timeOut : float

#Most these don't apply to melee weapons, I'll look into a way to get them to not dispaly when weapontype is set to melee
@export var fireRate : float 
@export var projectileSpeed : float 
@export var maxAmmo : int
@export var full_auto: bool

@export_category("Recoil")
@export var weaponRecoil : float
@export var weaponWeight : float
@export var gripLoss : float #do we want to make this dependent on reocil/rate of fire?

@export_category("Audio") #TODO: need to properly implement this
@export var fireSounds : Array[AudioStream] #this way if we have multiple sound effects we can have varied shooting sounds
@export var discardSound : AudioStream #when you drop the weapon or run out of ammo

@export_category("Technical Stuff")
@export var exitPadding : float

#These functions can be called off the resource object (probably make these into basic things like shooting if we get there)
func _test() -> void:
	print(weaponDamage)

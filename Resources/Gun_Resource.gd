extends Resource
class_name GunResource

#The goal is to have resources made for each gun that can be loaded into the normal gun script to set all the variables as needed
#Then we can quickly switch between guns and any edits can be made across all of them (since a change to the gun script will affect how these variables are handled)

#Sprites
@export_category("Sprites")
@export var weaponSprite : Texture2D
@export var bullet : PackedScene
@export var smoke : PackedScene

#Bullet information (if its a melee weapon ignore the rest)
@export_category("Damage Settings")
enum WeaponType { BULLET, MELEE, LASER} #I think we'll need to make sure this matches the gun script, at least until I find a better way to handle it (maybe making another script that both reference defining the enum)
@export var weaponType : WeaponType
@export var weaponDamage : float #TODO: need to properly implement this (edit bullet scene?) do we want to construct bullets here or have that as a seperate resource?

#Most these don't apply to melee weapons, I'll look into a way to get them to not dispaly when weapontype is set to melee
@export var fireRate : float 
@export var projectileSpeed : float 
@export var maxAmmo : int

@export_category("Recoil")
@export var weaponRecoil : float
@export var weaponWeight : float
@export var gripLoss : float #do we want to make this dependent on reocil/rate of fire?

@export_category("Audio") #TODO: need to properly implement this
@export var fireSound : Array[AudioStream] #this way if we have multiple sound effects we can have varied shooting sounds
@export var discardSound : AudioStream #when you drop the weapon or run out of ammo

@export_category("Technical Stuff")
@export var exitPadding : float

#These functions can be called off the resource object (probably make these into basic things like shooting if we get there)
func _test() -> void:
	print(weaponDamage)

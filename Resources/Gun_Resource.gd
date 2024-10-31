extends Resource
class_name GunResource

#The goal is to have resources made for each gun that can be loaded into the normal gun script to set all the variables as needed
#Then we can quickly switch between guns and any edits can be made across all of them (since a change to the gun script will affect how these variables are handled)

#Sprites
@export_category("Sprites")
@export var weaponSprite : Texture2D
@export var bulletSprite : Texture2D #TODO will need to access the bullet scene to edit this maybe? or just make this the bullet scene (same for damage)
@export var smoke : Texture2D #TODO will need to access the smoke scene to edit this maybe? or just make this the smoke scene

#Bullet information (if its a melee weapon ignore the rest)
@export_category("Damage Settings")
enum WeaponType { BULLET, MELEE, LASER} #I think we'll need to make sure this matches the gun script, at least until I find a better way to handle it (maybe making another script that both reference defining the enum)
@export var weaponType : WeaponType
@export var weaponDamage : float

#Most these don't apply to melee weapons, I'll look into a way to get them to not dispaly when weapontype is set to melee
@export var fireRate : float 
@export var projectileSpeed : float 
@export var maxAmmo : int

@export_category("Recoil")
@export var weaponRecoil : float
@export var weaponWeight : float
@export var recoilLoss : float #do we want to make this dependent on reocil/rate of fire?

@export_category("Technical Stuff")
@export var exitPadding : float

#These functions can be called off the resource object (probably make these into basic things like shooting if we get there)
func _test() -> void:
	print(weaponDamage)

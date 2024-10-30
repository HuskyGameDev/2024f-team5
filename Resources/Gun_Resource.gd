extends Resource
class_name GunResource

#The goal of this is to make creating a new gun as simple as filling in the following variables

#Sprites
@export_category("Sprites")
@export var weaponSprite : Texture2D
@export var bulletSprite : Texture2D

#Functionality info
@export_category("Functionality")
@export var weaponType : int #TODO: change this to probably be an enum
@export var weaponRecoil : float
@export var weaponDamage : float #this is per bullet if a gun
@export var weaponWeight : float
@export var recoilLoss : float #do we want to make this dependent on reocil/rate of fire?
@export var fireRate : float
@export var projectileSpeed : float

func _test() -> void:
	print(weaponDamage)

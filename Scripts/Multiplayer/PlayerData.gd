class_name PlayerData extends Node

@export var username: String
@export var uuid: int
@export var isAdmin: bool
@export var skin: PlayerSkin
@export var authenticated: bool = false

enum PlayerSkin{
	RED,
	GREEN,
	BLUE,
	PURPLE,
	YELLOW,
	ORANGE,
	BLACK,
	WHITE
}

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if (!is_multiplayer_authority()): return
	if (get_node_or_null("/root/PlayerData") == null): return
	username = $/root/PlayerData.username
	uuid = name.to_int()
	$/root/PlayerData.queue_free()

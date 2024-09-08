class_name PlayerData extends Node

@export var username: String
@export var uuid: int
@export var gun: String #CHANGE THIS TO A GUN CLASS WHEN THAT EXISTS
@export var password: String

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if (!is_multiplayer_authority()): return
	if (get_node_or_null("/root/PlayerData") == null): return
	username = $/root/PlayerData.username
	uuid = name.to_int()
	$/root/PlayerData.queue_free()

@rpc("authority")
func kick() -> void:
	multiplayer.multiplayer_peer = null
	#var mainMenu: MainMenu = load("res://Scenes/Menu/main_menu.tscn").instantiate()
	#mainMenu.message("kicked")

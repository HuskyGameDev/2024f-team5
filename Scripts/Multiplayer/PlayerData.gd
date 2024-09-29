class_name PlayerData extends Node

@export var username: String
@export var color: Color
@export var uuid: int
@export var password: String
@export var isAdmin: bool
var authenticated: bool = false

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if (!is_multiplayer_authority()): return
	if (get_node_or_null("/root/PlayerData") == null): return
	username = $/root/PlayerData.username
	uuid = name.to_int()
	$/root/PlayerData.queue_free()

@rpc("any_peer")
func kick(reason: String) -> void:
	$/root/Root/MultiplayerManager.kick(reason)

@rpc("any_peer")
func getAuth(result: bool) -> void:
	if (result):
		authenticated = result
	else:
		kick("password")

@rpc("any_peer")
func authPassword(playerID: int, passwd: String) -> void:
	get_node("/root/Root/MultiplayerManager/" + str(playerID)).rpc_id(playerID, "getAuth", (passwd == password || password == ""))

#@rpc("any_peer", "call_local")
#func chatMessage(playerID: int, msg: String) -> void:
	#$/root/Root/Lobby/VBoxContainer/Content/Configuration/Chat/Control/Panel/Chat.append_text("\n<%s> %s" % [get_node("/root/Root/MultiplayerManager/%s" % str(playerID)).username, msg])

#@rpc("any_peer", "call_local")
#func chatAnnouncement(msg: String) -> void:
	#$/root/Root/Lobby/VBoxContainer/Content/Configuration/Chat/Control/Panel/Chat.append_text("\n[color=YELLOW]%s[/color]" % msg)

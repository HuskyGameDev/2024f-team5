class_name PlayerData extends Node

signal playerAuthenticated()

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
	var result: bool = (passwd == password || password == "")
	get_node("/root/Root/MultiplayerManager/" + str(playerID)).rpc_id(playerID, "getAuth", result)
	await get_tree().create_timer(1).timeout
	if (result): playerAuthenticated.emit()

# This method is not currently used, but since I had the infrastructure for it already, I left it
@rpc("any_peer", "call_local")
func chatMessage(playerID: int, msg: String) -> void:
	pass
	#Example code of how this is used in a different game using the same multiplayer system:
	#Chat.append_text("\n<%s> %s" % [get_node("/root/Root/MultiplayerManager/%s" % str(playerID)).username, msg])

# This method is not currently used, but since I had the infrastructure for it already, I left it
@rpc("any_peer", "call_local")
func chatAnnouncement(msg: String) -> void:
	pass
	#Example code of how this is used in a different game using the same multiplayer system:
	#Chat.append_text("\n[color=YELLOW]%s[/color]" % msg)

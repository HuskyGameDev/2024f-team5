class_name MultiplayerManager extends MultiplayerSpawner

signal playerListChanged()
signal playerLost(player: int)

@export var playerData: PackedScene

var peer: ENetMultiplayerPeer
var hosting: bool = false
var password: String
#var authenticationAttempts: int = 5
#var hostData: PlayerData
var data: PlayerData
var authenticated: bool = false

@rpc("any_peer")
func kick(reason: String) -> void:
	leaveServer()
	$/root/Root/Menu.notify(reason)

@rpc("any_peer")
func getAuth(result: bool) -> void:
	print("Authentication received")
	authenticated = result

@rpc("any_peer")
func authPassword(playerID: int, passwd: String) -> void:
	print("Authorization requested")
	if (passwd == password || password == ""):
		rpc_id(playerID, "getAuth", true)
		rpc("updatePlayerList", playerID)
	else:
		print("Authorization rejected")
		rpc_id(playerID, "kick", "Heh\nLoser got the password wrong")

@rpc("any_peer", "call_local")
func updatePlayerList(player: int) -> void:
	print("Emitting update signal")
	playerListChanged.emit()

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

func hostServer(port: int, upnp: bool, pswd: String) -> Error:
	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(port)
	if (error == Error.OK):
		hosting = true
		password = pswd
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(addPlayer)
		multiplayer.peer_disconnected.connect(removePlayer)
		addPlayer(1)
		if (upnp): upnpSetup(port)
	return error

func upnpSetup(port: int) -> String:
	var upnp: UPNP = UPNP.new()
	var _result: int = upnp.discover()
	var _map: int = upnp.add_port_mapping(port)
	return upnp.query_external_address()

func joinServer(ip: String, port: int) -> Error:
	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	multiplayer.server_disconnected.connect(serverClosed)
	return error

func addPlayer(id: int) -> void:
	var player: PlayerData = playerData.instantiate()
	player.uuid = id
	player.name = str(id)
	add_child(player)
	if (id == 1):
		#hostData = $'1'
		player.isAdmin = true
		return
	player.isAdmin = false
	await get_tree().create_timer(0.1).timeout

func removePlayer(id: int) -> void:
	for player: PlayerData in get_children():
		if (player.uuid == id): 
			playerLost.emit(player.uuid)
			player.queue_free()

func serverClosed() -> void:
	leaveServer()
	$/root/Root/Menu.message("connection")

func leaveServer() -> void:
	#data.rpc("chatAnnouncement", "%s left the game!" % data.username)
	multiplayer.multiplayer_peer = null
	$/root/Root.name = "OldRoot"
	var root: Node = load("res://Scenes/Root.tscn").instantiate()
	$/root.add_child(root)
	$/root/OldRoot.queue_free()

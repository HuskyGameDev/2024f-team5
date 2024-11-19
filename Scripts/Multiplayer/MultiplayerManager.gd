class_name MultiplayerManager extends MultiplayerSpawner

signal playerListChanged()
signal playerLost(player: int)

@export var playerData: PackedScene

var peer: ENetMultiplayerPeer
var hosting: bool = false
var password: String
var data: PlayerData
var authenticated: bool = false
var inLobby: bool = true
var readyPlayers: Dictionary

# Static reference added for other scripts to access. - Jay
static var instance: MultiplayerManager

func _ready() -> void:
	instance = self

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
	if (!inLobby):
		print("Rejected join request during gameplay")
		rpc_id(playerID, "kick", "Game already in progress")
	elif (passwd == password || password == ""):
		rpc_id(playerID, "getAuth", true)
		rpc("updatePlayerList")
	else:
		print("Authorization rejected")
		rpc_id(playerID, "kick", "Heh\nLoser got the password wrong")

@rpc("any_peer", "call_local")
func updatePlayerList() -> void:
	print("Emitting update signal")
	playerListChanged.emit()
	readyPlayers.clear()
	for peer: PlayerData in get_children():
		readyPlayers[peer.uuid] = false

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

# This method will be called by every client (including the host) from the lobby when the game
# is ready to start. It will tell all clients to delete the lobby and load a given map ID. Once
# loaded, each client will send a ready message to the host. Once all clients have given the signal,
# the host will begin the game. 
@rpc("any_peer", "call_local")
func loadMap(mapID: String) -> void:
	inLobby = false
	var map: Map = load("res://Scenes/Maps/%s.tscn" % mapID).instantiate()
	map.soloTest = false
	map.data = data
	map.multiplayerManager = self
	$/root/Root.add_child(map)
	$/root/Root/Lobby.queue_free()
	if (data.uuid == 1):
		while true:
			await get_tree().create_timer(0.25).timeout
			for r: bool in readyPlayers.values():
				if !r: continue
			rpc("beginGame")
			break

@rpc("any_peer", "call_local")
func mapLoaded(playerID: int) -> void:
	print("Map loaded")
	readyPlayers[playerID] = true

@rpc("any_peer", "call_local")
func beginGame() -> void:
	var map: Map = $/root/Root/Map
	if (data.uuid == 1):
		for player: PlayerData in get_children():
			map.spawnPlayer(player.uuid)
			print("Creating player %s" % str(player.uuid))
	print("Begin game")

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
	$/root/Root/Menu.notify("Server closed")

func leaveServer() -> void:
	multiplayer.multiplayer_peer = null
	get_parent().name = "OldRoot"
	var root: Node = load("res://Scenes/Root.tscn").instantiate()
	get_tree().root.add_child(root)
	await root.ready
	get_parent().queue_free()

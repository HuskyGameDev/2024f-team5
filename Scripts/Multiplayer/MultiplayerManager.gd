class_name MultiplayerManager extends MultiplayerSpawner

signal playerListChanged()

@export var playerData: PackedScene

var peer: ENetMultiplayerPeer
var hosting: bool = false
var password: String
var data: PlayerData
var authenticated: bool = false
var inLobby: bool = true
var readyPlayers: Dictionary
var playerCap: int = 8
var mapSelection: String = "testmap"
var roundLength: int = 3

# Static reference added for other scripts to access. - Jay
static var instance: MultiplayerManager

func _ready() -> void:
	instance = self

func getPlayerData(uuid: int) -> PlayerData:
	return get_node_or_null(str(uuid))

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
	elif (get_children().size() + 1 > playerCap):
		print("Rejected join request due to player cap")
		rpc_id(playerID, "kick", "Lobby is full")
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
	for player: PlayerData in get_children():
		readyPlayers[player.uuid] = false

# This method is not currently used, but since I had the infrastructure for it already, I left it
@rpc("any_peer", "call_local")
func chatMessage(_playerID: int, _msg: String) -> void:
	pass
	#Example code of how this is used in a different game using the same multiplayer system:
	#Chat.append_text("\n<%s> %s" % [get_node("/root/Root/MultiplayerManager/%s" % str(playerID)).username, msg])

# This method is not currently used, but since I had the infrastructure for it already, I left it
@rpc("any_peer", "call_local")
func chatAnnouncement(_msg: String) -> void:
	pass
	#Example code of how this is used in a different game using the same multiplayer system:
	#Chat.append_text("\n[color=YELLOW]%s[/color]" % msg)

# This method will be called by every client (including the host) from the lobby when the game
# is ready to start. It will tell all clients to delete the lobby and load a given map ID. Once
# loaded, each client will send a ready message to the host. Once all clients have given the signal,
# the host will begin the game. 
@rpc("any_peer", "call_local")
func loadMap(mapID: String, roundLen: int) -> void:
	inLobby = false
	roundLength = roundLen
	mapSelection = mapID
	var map: Map = load("res://Scenes/Maps/%s.tscn" % mapID).instantiate()
	map.soloTest = false
	map.data = data
	map.multiplayerManager = self
	map.roundLength = roundLength
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
	map.start()
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
		player.color = randi_range(0, 4) as PlayerData.PlayerColor
		player.emotion = randi_range(0, 4) as PlayerData.Emotion
		player.isAdmin = true
		return
	player.isAdmin = false
	await get_tree().create_timer(0.1).timeout

func removePlayer(id: int) -> void:
	for player: PlayerData in get_children():
		if (player.uuid == id): 
			#playerLost.emit(player.uuid)
			player.free()
			updatePlayerList()

func serverClosed() -> void:
	leaveServer()
	$/root/Root/Menu.notify("Server closed")

func leaveServer() -> void:
	$/root/PauseMenu.setMainMenu(true)
	multiplayer.multiplayer_peer = null
	get_parent().name = "OldRoot"
	var root: Node = load("res://Scenes/Root.tscn").instantiate()
	get_tree().root.add_child(root)
	get_parent().call_deferred("free")

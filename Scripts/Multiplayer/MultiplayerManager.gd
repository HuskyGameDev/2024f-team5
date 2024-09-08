class_name MultiplayerManager extends MultiplayerSpawner

signal playerAdded(player: PlayerData)
signal playerLost(player: int)

@export var playerData: PackedScene

var peer: ENetMultiplayerPeer
var hosting: bool = false
var password: String
var authenticationAttempts: int = 5
var authentication: Dictionary

func hostServer(port: int, upnp: bool, username: String, color: Color, password: String = "") -> Error:
	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(port)
	if (error == Error.OK):
		hosting = true
		password = $/root/Root/Menu/HostMenu/Password.text
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(addPlayer)
		multiplayer.peer_disconnected.connect(removePlayer)
		addPlayer(1)
		if (upnp): upnpSetup(port)
	return error

func upnpSetup(port: int) -> String:
	var upnp: UPNP = UPNP.new()
	var result: int = upnp.discover()
	var map: int = upnp.add_port_mapping(port)
	return upnp.query_external_address()

func joinServer(ip: String, port: int, password: String = "") -> Error:
	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	return error

func addPlayer(id: int) -> void:
	authentication[id] = false
	var player: PlayerData = playerData.instantiate()
	player.uuid = id
	player.name = str(id)
	add_child(player)
	playerAdded.emit(player)
	if (id == 1):
		authentication[id] = true
		return
	await get_tree().create_timer(0.1).timeout
	for i: int in range(authenticationAttempts):
		if (player.password == password):
			authentication[id] = true
			print("User Authenticated: %s" % player.username)
			return
		await get_tree().create_timer(1).timeout
	if (!authentication[id]):
		player.rpc("password")

func removePlayer(id: int) -> void:
	authentication.erase(id)
	for player: PlayerData in get_children():
		if (player.uuid == id): 
			playerLost.emit(player.uuid)
			player.queue_free()

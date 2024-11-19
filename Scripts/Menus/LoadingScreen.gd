class_name LoadingScreen extends Control

@onready var statusLabel: RichTextLabel = $Status
@onready var multiplayerManager: MultiplayerManager = $/root/Root/MultiplayerManager
@onready var lobbyScene: PackedScene = preload("res://Scenes/Menus/Lobby.tscn")

@export var bufferTime: float = 0.1
@export var timeoutLength: float = 10
@export var isAdmin: bool = false
@export var password: String

var data: PlayerData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	statusLabel.text = "[center]Connecting...[/center]"
	await get_tree().create_timer(bufferTime).timeout
	var timeoutTimer: SceneTreeTimer = get_tree().create_timer(timeoutLength)
	timeoutTimer.timeout.connect(timeout)
	while (!is_instance_valid(data)):
		for player: PlayerData in multiplayerManager.get_children():
			if (player.is_multiplayer_authority()):
				data = player
				multiplayerManager.data = player
				break
		await get_tree().create_timer(0.5).timeout
	timeoutTimer.timeout.disconnect(timeout)
	statusLabel.text = "[center]Authenticating...[/center]"
	if (data.uuid != 1):
		multiplayerManager.rpc_id(1, "authPassword", data.uuid, password)
		print("Password: %s" % password)
		get_tree().create_timer(timeoutLength).timeout.connect(timeout)
		while (!isAdmin && !multiplayerManager.authenticated):
			await get_tree().create_timer(0.5).timeout
	data.authenticated = true
	var lobby: Lobby = lobbyScene.instantiate()
	lobby.data = data
	#lobby.hostData = hostData
	lobby.isAdmin = isAdmin
	$/root/Root.add_child(lobby)
	queue_free()

func timeout() -> void:
	multiplayerManager.kick("Connection timeout")

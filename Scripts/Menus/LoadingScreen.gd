class_name LoadingScreen extends Control

@onready var statusLabel: RichTextLabel = $Status
@onready var multiplayerManager: MultiplayerManager = $/root/Root/MultiplayerManager
@onready var lobbyScene: PackedScene = preload("res://Scenes/Menus/Lobby.tscn")

@export var bufferTime: float = 0.1
@export var timeoutLength: float = 10
@export var isAdmin: bool = false
@export var password: String

var data: PlayerData
var hostData: PlayerData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	statusLabel.text = "[center]Connecting...[/center]"
	await get_tree().create_timer(bufferTime).timeout
	while (!is_instance_valid(data)):
		for player: PlayerData in multiplayerManager.get_children():
			if (player.is_multiplayer_authority()):
				data = player
				multiplayerManager.data = player
				break
		await get_tree().create_timer(0.5).timeout
	hostData = $'/root/Root/MultiplayerManager/1'
	statusLabel.text = "[center]Authenticating...[/center]"
	if (data.uuid != 1):
		hostData.rpc_id(1, "authPassword", data.uuid, password)
		print("Password: %s" % password)
		get_tree().create_timer(timeoutLength).timeout.connect(timeout)
		while (!isAdmin && !data.authenticated):
			await get_tree().create_timer(0.5).timeout
	var lobby: Lobby = lobbyScene.instantiate()
	lobby.data = data
	lobby.hostData = hostData
	lobby.isAdmin = isAdmin
	$/root/Root.add_child(lobby)
	queue_free()

func timeout() -> void:
	if (!data.authenticated): data.kick("timeout")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

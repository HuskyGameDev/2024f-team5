class_name Lobby extends Control

@onready var multiplayerManager: MultiplayerManager = $/root/Root/MultiplayerManager

@export var bufferTime: float = 0.1
@export var timeoutLength: float = 10

var data: PlayerData
var hostData: PlayerData
var isAdmin: bool = false
var password: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(bufferTime).timeout
	while (!is_instance_valid(data)):
		for player: PlayerData in multiplayerManager.get_children():
			if (player.is_multiplayer_authority()):
				data = player
				multiplayerManager.data = player
				break
		await get_tree().create_timer(0.5).timeout
	hostData = $'/root/Root/MultiplayerManager/1'

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

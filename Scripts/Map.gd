class_name Map extends Node2D

# Might not be needed anymore. Commenting just in case
#signal mapLoaded()

var playerScene: PackedScene = preload("res://Scenes/Objects/player.tscn")

@export var soloTest: bool = true
@export var data: PlayerData
@export var multiplayerManager: MultiplayerManager
@onready var hud: Hud = $CanvasLayer/PlayerHud
@export var roundLength: int = 3

func _ready() -> void:
	name = "Map" #DO NOT CHANGE THIS LINE. IT IS IMPORTANT. 
	if (soloTest):
		var player: Player = playerScene.instantiate()
		player.singleplayerTesting = true
		$Players.add_child(player)
	else:
		print("Map instantiated")
		multiplayerManager.rpc_id(1, "mapLoaded", data.uuid)
	$CanvasLayer/ffa_dm/Timer.wait_time = roundLength * 60

## Create a player with a specified multiplayer authority
func spawnPlayer(authority: int) -> void:
	var player: Player = playerScene.instantiate()
	player.name = str(authority)
	$Players.add_child(player)

func start() -> void:
	$CanvasLayer/ffa_dm/Timer.start()

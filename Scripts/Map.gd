class_name Map extends Node2D

var playerScene: PackedScene = preload("res://Scenes/Objects/player.tscn")

static var current_map: Map

@export var soloTest: bool = true
@export var data: PlayerData
@export var multiplayerManager: MultiplayerManager
@onready var hud: Hud = $CanvasLayer/PlayerHud
@export var roundLength: int = 3
@export var songs: Array[AudioStream]
@export var spawn_points: Array[Vector2]

var musicPlayer: AudioStreamPlayer

func _ready() -> void:
	name = "Map" #DO NOT CHANGE THIS LINE. IT IS IMPORTANT. 
	current_map = self
	if (soloTest):
		var player: Player = playerScene.instantiate()
		player.singleplayerTesting = true
		$Players.add_child(player)
	else:
		print("Map instantiated")
		multiplayerManager.rpc_id(1, "mapLoaded", data.uuid)
	$CanvasLayer/ffa_dm/Timer.wait_time = roundLength * 60
	songs.append(load("res://SFX/Music/Slompin.wav"))
	musicPlayer = AudioStreamPlayer.new()
	musicPlayer.bus = "Music"
	musicPlayer.finished.connect(playRandomSong)
	musicPlayer.volume_db = -15
	add_child(musicPlayer)
	playRandomSong()

## Create a player with a specified multiplayer authority
func spawnPlayer(authority: int) -> void:
	var player: Player = playerScene.instantiate()
	player.name = str(authority)
	$Players.add_child(player)

func start() -> void:
	$CanvasLayer/ffa_dm/Timer.start()

func playRandomSong() -> void:
	musicPlayer.stream = songs.pick_random()
	musicPlayer.play()

func getRandomSpawn() -> Vector2:
	if(spawn_points.is_empty()):
		print("respawn points are not set on this map!")
		# Default to (0,0) if no points specified
		return Vector2(0, 0)
	return spawn_points.pick_random()
	

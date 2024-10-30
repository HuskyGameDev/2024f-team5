class_name Lobby extends Control

@onready var multiplayerManager: MultiplayerManager = $/root/Root/MultiplayerManager
@onready var playerList: VBoxContainer = $PlayerList
@onready var nameplateScene: PackedScene = preload("res://Scenes/Menus/MenuNameplate.tscn")

@export var bufferTime: float = 0.1
@export var timeoutLength: float = 10

var data: PlayerData
#var hostData: PlayerData
var isAdmin: bool = false
var password: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayerManager.playerListChanged.connect(updatePlayerList)
	updatePlayerList()

func updatePlayerList() -> void:
	print("Updating list")
	for nameplate: MenuNameplate in playerList.get_children():
		nameplate.free()
	for player: PlayerData in multiplayerManager.get_children():
		var nameplate: MenuNameplate = nameplateScene.instantiate()
		playerList.add_child(nameplate)
		nameplate.setPlayer(player)

func _on_begin_pressed() -> void:
	multiplayerManager.rpc("loadMap", "houghton")

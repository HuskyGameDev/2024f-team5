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
	#if (isAdmin):
		#multiplayerManager.child_entered_tree.connect(multiplayerManager.updatePlayerList)
		#multiplayerManager.child_exiting_tree.connect(multiplayerManager.updatePlayerList)
		#playerConnected(data)
	multiplayerManager.playerListChanged.connect(updatePlayerList)
	updatePlayerList()

#func playerConnected(player: PlayerData) -> void:
	#print("Creating %s" % player.username)
	#var nameplate: MenuNameplate = nameplateScene.instantiate()
	#playerList.add_child(nameplate)
	#nameplate.setPlayer(player)
#
#func playerDisconnected(player: PlayerData) -> void:
	#for nameplate: MenuNameplate in playerList.get_children():
		#if (str(player.uuid) == nameplate.name):
			#nameplate.queue_free()
			#break

func updatePlayerList() -> void:
	print("Updating list")
	for nameplate: MenuNameplate in playerList.get_children():
		nameplate.free()
	for player: PlayerData in multiplayerManager.get_children():
		var nameplate: MenuNameplate = nameplateScene.instantiate()
		playerList.add_child(nameplate)
		nameplate.setPlayer(player)

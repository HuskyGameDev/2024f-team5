class_name Lobby extends Control

@onready var multiplayerManager: MultiplayerManager = $/root/Root/MultiplayerManager
@onready var playerList: VBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer/PlayerList/PlayerList
@onready var nameplateScene: PackedScene = preload("res://Scenes/Menus/MenuNameplate.tscn")
@onready var mapSelection: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/Settings/ScrollContainer/VBoxContainer/MapSelection
@onready var playerCap: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/Settings/ScrollContainer/VBoxContainer/SpinBox
@onready var usernameEntry: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/Settings/ScrollContainer/VBoxContainer/UsernameEntry

@export var bufferTime: float = 0.1
@export var timeoutLength: float = 10

var data: PlayerData
var isAdmin: bool = false
var password: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (multiplayerManager.hosting):
		mapSelection.disabled = false
		mapSelection.item_selected.connect(_on_map_selection_item_selected)
		playerCap.editable = true
		playerCap.value_changed.connect(_on_spin_box_value_changed)
		$MarginContainer/VBoxContainer/Begin.show()
	usernameEntry.text = data.username
	multiplayerManager.playerListChanged.connect(updatePlayerList)
	updatePlayerList()

func updatePlayerList() -> void:
	print("Updating list")
	for nameplate: MenuNameplate in playerList.get_children():
		nameplate.free()
	for player: PlayerData in multiplayerManager.get_children():
		var nameplate: MenuNameplate = nameplateScene.instantiate()
		playerList.add_child(nameplate)
		nameplate.multiplayerManager = multiplayerManager
		nameplate.setPlayer(player, multiplayerManager.hosting && player.uuid != 1)

func _on_begin_pressed() -> void:
	match mapSelection.selected:
		0:
			multiplayerManager.rpc("loadMap", "houghton")
		1:
			multiplayerManager.rpc("loadMap", "Map1")

func _on_username_entry_text_changed(new_text: String) -> void:
	data.username = new_text
	multiplayerManager.call_deferred("rpc", "updatePlayerList")

func _on_map_selection_item_selected(index: int) -> void:
	rpc("updateGameSettings", index, playerCap.value)

func _on_spin_box_value_changed(value: int) -> void:
	if (multiplayerManager.get_children().size() > value):
		playerCap.value = multiplayerManager.get_children().size()
	else:
		multiplayerManager.playerCap = value
		rpc("updateGameSettings", mapSelection.selected, multiplayerManager.playerCap)

@rpc("call_local")
func updateGameSettings(map: int, cap: int) -> void:
	mapSelection.selected = map
	playerCap.value = cap

class_name Lobby extends Control

@onready var multiplayerManager: MultiplayerManager = $/root/Root/MultiplayerManager
@onready var playerList: VBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer/PlayerList/PlayerList
@onready var nameplateScene: PackedScene = preload("res://Scenes/Menus/MenuNameplate.tscn")
@onready var mapSelection: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/Settings/ScrollContainer/VBoxContainer/MapSelection
@onready var playerCap: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/Settings/ScrollContainer/VBoxContainer/SpinBox
@onready var usernameEntry: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/Settings/ScrollContainer/VBoxContainer/HBoxContainer2/UsernameEntry
@onready var colorPick: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/Settings/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer/ColorSelection
@onready var emotionPick: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/Settings/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer/EmotionSelection
@onready var skinDisplay: Sprite2D = $MarginContainer/VBoxContainer/HBoxContainer/Settings/ScrollContainer/VBoxContainer/HBoxContainer/Panel/Preview
@onready var gamemodeSelection: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/Settings/ScrollContainer/VBoxContainer/GamemodeSelection
@onready var timelimitSelection: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/Settings/ScrollContainer/VBoxContainer/TimeLimitSelection

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
		gamemodeSelection.disabled = false
		gamemodeSelection.item_selected.connect(_on_gamemode_selection_item_selected)
		timelimitSelection.editable = true
		timelimitSelection.value_changed.connect(_on_time_limit_selection_value_changed)
		$MarginContainer/VBoxContainer/Begin.show()
	colorPick.selected = data.color
	emotionPick.selected = data.emotion
	skinChanged(0)
	usernameEntry.text = data.username
	multiplayerManager.playerListChanged.connect(updatePlayerList)
	updatePlayerList()

func updatePlayerList() -> void:
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
			multiplayerManager.rpc("loadMap", "houghton", timelimitSelection.value)
		1:
			multiplayerManager.rpc("loadMap", "Map1", timelimitSelection.value)
		2:
			multiplayerManager.rpc("loadMap", "testmap", timelimitSelection.value)

func _on_username_entry_text_changed(new_text: String) -> void:
	data.username = new_text
	updatePlayerList()

func _on_username_submit_pressed() -> void:
	data.username = usernameEntry.text
	updatePlayerList()

func _on_map_selection_item_selected(index: int) -> void:
	rpc("updateGameSettings", index, playerCap.value, timelimitSelection.value)

func _on_spin_box_value_changed(value: int) -> void:
	if (multiplayerManager.get_children().size() > value):
		playerCap.value = multiplayerManager.get_children().size()
	else:
		multiplayerManager.playerCap = value
		rpc("updateGameSettings", mapSelection.selected, multiplayerManager.playerCap, timelimitSelection.value)

@rpc("call_local")
func updateGameSettings(map: int, cap: int, time: int) -> void:
	mapSelection.selected = map
	playerCap.value = cap
	timelimitSelection.value = time

func skinChanged(_index: int) -> void:
	data.color = colorPick.selected as PlayerData.PlayerColor
	data.emotion = emotionPick.selected as PlayerData.Emotion
	var image: String = colorPick.get_item_text(colorPick.selected).to_lower() + "_" + emotionPick.get_item_text(emotionPick.selected).to_lower() + ".png"
	skinDisplay.texture = load("res://Sprites/Player/Skins/%s" % image)

func _on_timer_timeout() -> void:
	updatePlayerList()

func _on_time_limit_selection_value_changed(value: int) -> void:
	rpc("updateGameSettings", mapSelection.selected, multiplayerManager.playerCap, value)

#TODO eventually maybe
func _on_gamemode_selection_item_selected(index: int) -> void:
	pass # Replace with function body.

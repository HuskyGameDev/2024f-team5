class_name MainMenu extends Control

@onready var multiplayerManager: MultiplayerManager = $/root/Root/MultiplayerManager
@onready var loadingScreen: PackedScene = preload("res://Scenes/Menus/LoadingScreen.tscn")

func _ready() -> void:
	backPressed()

func _on_host_pressed() -> void:
	var loading: LoadingScreen = loadingScreen.instantiate()
	loading.isAdmin = true
	$/root/Root.add_child(loading)
	print(multiplayerManager.hostServer($Host/GridContainer/PortEntry.value, false, $Host/GridContainer/PasswordEntry.text))
	var data: PlayerData = $'/root/Root/MultiplayerManager/1'
	data.username = "Placeholder Name"
	queue_free()

func _on_join_pressed() -> void:
	var data: PlayerData = PlayerData.new()
	data.username = "Placeholder Joiner"
	data.name = "PlayerData"
	$/root.add_child(data)
	var loading: LoadingScreen = loadingScreen.instantiate()
	$/root/Root.add_child(loading)
	print(multiplayerManager.joinServer($Join/GridContainer/IPEntry.text, $Join/GridContainer/PortEntry.value))
	queue_free()

func _on_host_menu_pressed() -> void:
	$Main.hide()
	$Host.show()

func _on_join_menu_pressed() -> void:
	$Main.hide()
	$Join.show()

func _on_settings_pressed() -> void:
	print("Not yet added")

func _on_quit_pressed() -> void:
	get_tree().quit()

func backPressed() -> void:
	$Main.show()
	$Host.hide()
	$Join.hide()
	$Settings.hide()

func notify(msg: String) -> void:
	$Notification.show()
	$Notification/Panel/RichTextLabel.text = "[center]%s[/center]" % msg

func _on_close_pressed() -> void:
	$Notification.hide()

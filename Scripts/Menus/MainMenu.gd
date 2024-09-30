class_name MainMenu extends Control

@onready var multiplayerManager: MultiplayerManager = $/root/Root/MultiplayerManager
@onready var loadingScreen: PackedScene = preload("res://Scenes/Menus/LoadingScreen.tscn")

func _ready() -> void:
	backPressed()

func _on_host_pressed() -> void:
	var loading: LoadingScreen = loadingScreen.instantiate()
	loading.setAdmin()
	#multiplayerManager.child_entered_tree.connect(lobby.playerConnected)
	#multiplayerManager.child_exiting_tree.connect(lobby.playerDisconnected)
	$/root/Root.add_child(loading)
	print(multiplayerManager.hostServer($Host/GridContainer/PortEntry.value, false))
	#setPlayerData()
	queue_free()

func _on_join_pressed() -> void:
	pass # Replace with function body.

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

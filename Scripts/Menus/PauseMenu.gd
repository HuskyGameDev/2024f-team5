class_name PauseMenu extends CanvasLayer

@onready var pauseMenu: VBoxContainer = $Panel/Pause
@onready var settingsMenu: VBoxContainer = $Panel/Settings
@onready var fpsCounter: FPSCounter = $/root/FPSCounter

var multiplayerManager: MultiplayerManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("escape")):
		visible = !visible
		_on_back_pressed()

# ---- Pause Menu ---- #
func _on_resume_pressed() -> void:
	hide()

func _on_settings_pressed() -> void:
	pauseMenu.hide()
	settingsMenu.show()

func _on_disconnect_pressed() -> void:
	multiplayerManager.leaveServer()

func _on_desktop_pressed() -> void:
	get_tree().quit()


# ---- Settings Menu ---- #
func _on_back_pressed() -> void:
	settingsMenu.hide()
	pauseMenu.show()

# -- Video -- #
func _on_window_mode_item_selected(index: int) -> void:
	match (index):
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(DisplayServer.screen_get_size() / 2)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _on_v_sync_item_selected(index: int) -> void:
	# Looks like the dropdown and the enum matches up, so this should work
	DisplayServer.window_set_vsync_mode(index)
	#match (index):
		#0:
			#DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		#1:
			#DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		#2:
			#DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		#3:
			#DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)

func _on_max_fps_item_selected(index: int) -> void:
	match index:
		0: Engine.max_fps = 0
		1: Engine.max_fps = 24
		2: Engine.max_fps = 30
		3: Engine.max_fps = 60
		4: Engine.max_fps = 90
		5: Engine.max_fps = 120
		6: Engine.max_fps = 144
		7: Engine.max_fps = 240

func _on_fps_counter_item_selected(index: int) -> void:
	fpsCounter.setState(index)


# -- Audio -- #
func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_effects_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_reset_audio_pressed() -> void:
	AudioServer.set_bus_volume_db(0, 0)
	AudioServer.set_bus_volume_db(1, 0)
	AudioServer.set_bus_volume_db(2, 0)
	$Panel/Settings/MarginContainer/VBoxContainer/TabContainer/Audio/ScrollContainer/VBoxContainer/MasterVolume.value = 1
	$Panel/Settings/MarginContainer/VBoxContainer/TabContainer/Audio/ScrollContainer/VBoxContainer/MusicVolume.value = 1
	$Panel/Settings/MarginContainer/VBoxContainer/TabContainer/Audio/ScrollContainer/VBoxContainer/EffectsVolume.value = 1

# This method only exists for debugging
func printBusses() -> void:
	print("Master: %s\nMusic: %s\nEffects: %s\n" % [AudioServer.get_bus_volume_db(0), AudioServer.get_bus_volume_db(1), AudioServer.get_bus_volume_db(2)])

# -- Controls -- #

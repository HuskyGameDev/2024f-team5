class_name PauseMenu extends CanvasLayer

@onready var pauseMenu: VBoxContainer = $Panel/Pause
@onready var settingsMenu: VBoxContainer = $Panel/Settings

var multiplayerManager: MultiplayerManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("escape")):
		visible = !visible
		_on_back_pressed()

# --- Pause Menu --- #
func _on_resume_pressed() -> void:
	hide()

func _on_settings_pressed() -> void:
	pauseMenu.hide()
	settingsMenu.show()

func _on_disconnect_pressed() -> void:
	multiplayerManager.leaveServer()

func _on_desktop_pressed() -> void:
	get_tree().quit()


# --- Settings Menu --- #
func _on_back_pressed() -> void:
	settingsMenu.hide()
	pauseMenu.show()

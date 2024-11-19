class_name MenuNameplate extends HBoxContainer

@onready var textbox: RichTextLabel = $Name

@export var isAdmin: bool = false
@export var multiplayerManager: MultiplayerManager

var data: PlayerData

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func setPlayer(player: PlayerData, admin: bool) -> void:
	textbox.text = "[right]%s[/right]" % player.username
	name = str(player.uuid)
	data = player
	if (admin): $KickButton.show()

func kickPressed() -> void:
	multiplayerManager.rpc_id(data.uuid, "kick", "kicked")

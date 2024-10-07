class_name MenuNameplate extends HBoxContainer

@onready var textbox: RichTextLabel = $Name

@export var isAdmin: bool = false

var data: PlayerData

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func setPlayer(player: PlayerData) -> void:
	textbox.text = "[center]%s[/center]" % player.username
	name = str(player.uuid)
	data = player

func kickPressed() -> void:
	data.rpc_id(data.uuid, "kick", "kicked")

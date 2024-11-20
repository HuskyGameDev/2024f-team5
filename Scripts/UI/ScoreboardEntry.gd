class_name ScoreboardEntry extends Control

@export var score: int = 0
@export var user: String

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	user = MultiplayerManager.instance.data.username

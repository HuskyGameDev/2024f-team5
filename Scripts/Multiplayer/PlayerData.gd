class_name PlayerData extends Node

@export var username: String
@export var uuid: int
@export var isAdmin: bool
@export var color: PlayerColor = 3
@export var emotion: Emotion = 2
@export var authenticated: bool = false

enum PlayerColor{
	BLUE,
	GREEN,
	PURPLE,
	RED,
	YELLOW
}
enum Emotion{
	HAPPY,
	MEH,
	NEUTRAL,
	MAD,
	SAD
}

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if (!is_multiplayer_authority()): return
	if (get_node_or_null("/root/PlayerData") == null): return
	username = $/root/PlayerData.username
	uuid = name.to_int()
	color = randi_range(0, 4)
	emotion = randi_range(0, 4)
	$/root/PlayerData.queue_free()

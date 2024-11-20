class_name PlayerData extends Node

@export var username: String
@export var uuid: int
@export var isAdmin: bool
@export var color: PlayerColor
@export var emotion: Emotion
@export var authenticated: bool = false
@export var score: int = 0

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
	color = randi_range(0, 4) as PlayerColor
	emotion = randi_range(0, 4) as Emotion
	$/root/PlayerData.queue_free()

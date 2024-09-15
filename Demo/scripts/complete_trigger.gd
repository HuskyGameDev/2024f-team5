# Commit test

extends Area2D
class_name CompleteTrigger
## This probably shouldn't be used in the final game.
## It's just a placeholder to show that the game is complete.
## Jay Hawkins
@export var text: Node

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		text.visible = true
		get_tree().paused = true

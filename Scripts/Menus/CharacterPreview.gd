class_name CharacterPreview extends Panel

@onready var renderer: Sprite2D = $Preview
@onready var animator: AnimationPlayer = $AnimationPlayer

var animations: Array[String] = [
	"idle",
	"look_up",
	"crouch",
	"run"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animator.play("idle")

func _on_animation_player_animation_finished(_anim_name: String) -> void:
	animator.play(animations.pick_random())

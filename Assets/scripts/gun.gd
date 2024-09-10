extends Node2D
class_name Gun
## This should probably be a resource or whatever Nolan was talking about
## But idk how to do allat
## Basically this determines basic gun behaviour
## Jay Hawkins

const REVERSE_OFFSET = -48
const SHOOT_VELOCITY = 400 

@onready var spi: Sprite2D = $Sprite2D
@onready var snd: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _shoot(mousepos: Vector2) -> void:
	var par: Node = get_parent()
	var diff: Vector2 = mousepos - self.global_position
	var angle: float = diff.angle() + PI
	var recoil: Vector2 = Vector2(cos(angle), sin(angle)) * SHOOT_VELOCITY
	par.velocity += recoil
	snd.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mousepos: Vector2 = get_global_mouse_position()
	look_at(mousepos)
	if(mousepos.x < global_position.x):
		spi.offset.x = REVERSE_OFFSET
		spi.flip_h = true
		rotation += 135 # i dont know why its 135 and not 180 but whatever
	else:
		spi.offset.x = 0
		spi.flip_h = false
		
	if(Input.is_action_just_pressed("shoot")):
		_shoot(mousepos)

# Temporary handling of HUD that we can go back and change later.
# Not liking the current use of statics.
# Jay Hawkins
extends CanvasLayer
class_name Hud

static var ammo_counter: Label
static var grip_bar: TextureRect
static var grip_fill: ColorRect
static var univ_grip_colors: Array[Color]

@export var grip_colors: Array[Color]

func _on_ready() -> void:
	ammo_counter = $AmmoCounter
	grip_bar = $GripBar
	grip_fill = $GripBar/Fill
	univ_grip_colors = grip_colors

static func update_grip(grip: float) -> void:
	grip_fill.scale.x = grip / 100
	if(grip < 25):
		grip_fill.color = univ_grip_colors[2]
	elif(grip < 50):
		grip_fill.color = univ_grip_colors[1]
	else:
		grip_fill.color = univ_grip_colors[0]
		

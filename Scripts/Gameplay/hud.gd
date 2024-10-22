## The HUD group for one player's display.
# Jay Hawkins
extends CanvasLayer
class_name Hud

@onready var ammo_counter: Label = $AmmoCounter
@onready var grip_bar: TextureRect = $GripBar
@onready var grip_fill: ColorRect = $GripBar/Fill
@export var grip_colors: Array[Color]

func update_grip(grip: float) -> void:
	grip_fill.scale.x = grip / 100
	if(grip < 25):
		grip_fill.color = grip_colors[2]
	elif(grip < 50):
		grip_fill.color = grip_colors[1]
	else:
		grip_fill.color = grip_colors[0]

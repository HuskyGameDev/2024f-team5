class_name Player
extends CharacterBody2D
## HANDLES PLAYER CONTROLS AND SHIT
## Jay Hawkins

const SPEED = 55.0
const JUMP_VELOCITY = -200.0
const Y_VEL_ANIM_THRESH = 60 # The threshold where the neutral jump animation is played
const X_ACCELERATION = 30
const X_DECELERATION = 10

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var equipped_item: Node = null

var cursors: Array = [
	preload("res://Assets/Sprites/crosshair1hires.png"), 
	preload("res://Assets/Sprites/crosshair2hires.png"),
	preload("res://Assets/Sprites/crosshair3hires.png")
]

func _ready() -> void:
	anim.play("idle")

func _physics_process(delta: float) -> void:
	# Add the gravity and handle jumping animation.
	if not is_on_floor():
		if(velocity.y > Y_VEL_ANIM_THRESH):
			anim.play("jump_down")
		elif(velocity.y < -Y_VEL_ANIM_THRESH):
			anim.play("jump_up")
		else:
			anim.play("jump_neutral")
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		if(direction < 0):
			anim.flip_h = true
		else:
			anim.flip_h = false
		if is_on_floor():
			anim.play("run")
		# doesn't immediately set
		# using move_toward allows for the player to use movement keys to
		# decelerate faster or slower from recoil.
		velocity.x = move_toward(velocity.x, direction * SPEED, X_ACCELERATION)
	else:
		if(is_on_floor()):
			anim.play("idle")
		velocity.x = move_toward(velocity.x, 0, X_DECELERATION)
		

	move_and_slide()

func die() -> void:
	unequip()
	# Godot doesn't like reloading scenes on collision enter.
	get_tree().call_deferred("reload_current_scene")

# Called on item pickup. Equips node item.
func equip(item: Node) -> void:
	add_child(item)
	equipped_item = item
	Input.set_custom_mouse_cursor(cursors[1], Input.CURSOR_ARROW, Vector2(16, 16))

# Unequips item
func unequip() -> void:
	equipped_item.queue_free()
	Input.set_custom_mouse_cursor(cursors[0], Input.CURSOR_ARROW, Vector2(16, 16))

func _on_mouse_entered() -> void:
	if(equipped_item != null):
		Input.set_custom_mouse_cursor(cursors[2], Input.CURSOR_ARROW, Vector2(16, 16))

func _on_mouse_exited() -> void:
	if(equipped_item != null):
		Input.set_custom_mouse_cursor(cursors[1], Input.CURSOR_ARROW, Vector2(16, 16))

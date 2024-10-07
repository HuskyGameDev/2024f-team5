class_name Player
extends CharacterBody2D
## HANDLES PLAYER CONTROLS AND SHIT
## Jay Hawkins

const SPEED: float = 75.0
const JUMP_VELOCITY: float = -225.0
const Y_VEL_ANIM_THRESH: float = 60 # The threshold where the neutral jump animation is played
# Player controls and DI on ground
const GROUND_ACCELERATION: float = 30
const GROUND_DECELERATION: float = 20
# Player controls and DI in air
const AIR_ACCELERATION: float = 17
const AIR_DECELERATION: float = 8
# Factor that friction increases by when crouched
const CROUCH_FACTOR: float = 2.2

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var death_parts: GPUParticles2D = $DeathParticles
@export var oob_death: PackedScene
var equipped_item: Node = null

var cursors: Array = [
	preload("res://Sprites/UI/crosshair1.png"), 
	preload("res://Sprites/UI/crosshair2.png"),
	preload("res://Sprites/UI/crosshair3.png")
]

var crouching: bool = false
var dead: bool = false

## Crouching increases "friction" of recoil. Can also be used to drop
## Through platforms in the future.
func crouch() -> void:
	anim.current_animation = "crouch"
	crouching = true

func uncrouch() -> void:
	crouching = false
	if(is_on_floor() && velocity.x == 0):
		anim.current_animation = "idle"

func _ready() -> void:
	anim.play("idle")

func _physics_process(delta: float) -> void:
	if(dead): return
	# Get the input direction and handle the movement/deceleration.
	var direction: float = Input.get_axis("move_left", "move_right")
	
	# Reset animations
	if(crouching && Input.is_action_just_released("crouch")):
		uncrouch()
	if(anim.current_animation == "look_up" && Input.is_action_just_released("look_up")):
		anim.current_animation = "idle"
	# Add the gravity and handle jumping animation.
	if not is_on_floor():
		uncrouch() # Can't crouch while airbourne
		if(velocity.y > Y_VEL_ANIM_THRESH):
			anim.play("jump_down")
		elif(velocity.y < -Y_VEL_ANIM_THRESH):
			anim.play("jump_up")
		else:
			anim.play("jump_neutral")
		velocity += get_gravity() * delta
	else:
		if(Input.is_action_pressed("crouch") && !direction):
			crouch()
		elif(Input.is_action_just_pressed("look_up")):
			anim.current_animation = "look_up"

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	
	if direction:
		uncrouch() # Can't crouch while moving
		if(direction < 0):
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		if is_on_floor():
			anim.play("run")
			velocity.x = move_toward(velocity.x, direction * SPEED, GROUND_ACCELERATION)
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, AIR_ACCELERATION)
			
		if is_on_wall_only() and Input.is_action_pressed("jump"): #Thomas's maddness
			velocity.y = move_toward(velocity.y, direction * (SPEED/2), GROUND_ACCELERATION)
	else:
		if(is_on_floor()):
			if(anim.current_animation != "crouch" && anim.current_animation != "look_up"):
				anim.current_animation = "idle"
			var dec: float = GROUND_DECELERATION
			if(crouching):
				dec *= CROUCH_FACTOR
			velocity.x = move_toward(velocity.x, 0, dec)
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_DECELERATION)

	var hit_ground: bool = is_on_floor()
	move_and_slide()
	if(hit_ground != is_on_floor()):
		anim.current_animation = "idle"

func die(oob: bool = false, theta: float = 0) -> void:
	dead = true
	# Out of bounds death animation
	if(oob):
		var od: Node2D = oob_death.instantiate()
		get_parent().add_child(od)
		od.position = position
		od.rotation = theta
		sprite.visible = false
	else: # Other death animation
		death_parts.emitting = true
		anim.current_animation = "die"
	unequip()
	set_deferred("collision.disabled", true)
	
	
	await get_tree().create_timer(3).timeout
	# Godot doesn't like reloading scenes on collision enter.
	get_tree().call_deferred("reload_current_scene")

# Called on item pickup. Equips node item.
func equip(item: Node) -> void:
	add_child(item)
	equipped_item = item
	Input.set_custom_mouse_cursor(cursors[1], Input.CURSOR_ARROW, Vector2(16, 16))

# Unequips item
func unequip() -> void:
	if (is_instance_valid(equipped_item)): equipped_item.queue_free()
	Input.set_custom_mouse_cursor(cursors[0], Input.CURSOR_ARROW, Vector2(16, 16))

func _on_mouse_entered() -> void:
	if(equipped_item != null):
		Input.set_custom_mouse_cursor(cursors[2], Input.CURSOR_ARROW, Vector2(16, 16))

func _on_mouse_exited() -> void:
	if(equipped_item != null):
		Input.set_custom_mouse_cursor(cursors[1], Input.CURSOR_ARROW, Vector2(16, 16))

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if(body.get_collision_layer() == 2):
		die()

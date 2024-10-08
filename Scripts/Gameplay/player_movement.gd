class_name Player
extends CharacterBody2D
## HANDLES PLAYER CONTROLS AND SHIT
## Jay Hawkins
## Some minor additions by Thomas Wilkins

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
#Thomas: Factor that friction increases by for wall cling
#Jay: I increased the factor, but decreased the amount of time you can cling
const CLING_FACTOR: float = 4.0
#Thomas: Factor that walljump strength decreases by, this is a divisor for the normal jump velocity
const WALLJUMP_FACTOR: float = 1.0
#Jay: The horizontal impulse recieved from walljumping to differentiate it from climbing
const WALLJUMP_IMPULSE: float = 150.0
#Thomas: number of times the player can consecutivley wall jump before needing to touch the ground
const MAX_WALLJUMPS: int = 3
#Thomas: this is the factor we'll use to divide the equipped items weight into a move speed penalty
const WEIGHT_TO_SPEED_FACTOR: float = 1 #going to default to a quarter of weapon weight becomes move penalty

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var death_parts: GPUParticles2D = $DeathParticles
@onready var walljumpTimer: Timer = $WalljumpTimer
@onready var cling_timer: Timer = $ClingTimer
@export var oob_death: PackedScene
var equipped_item: Node = null

var cursors: Array = [
	preload("res://Sprites/UI/crosshair1.png"), 
	preload("res://Sprites/UI/crosshair2.png"),
	preload("res://Sprites/UI/crosshair3.png")
]

var crouching: bool = false
var dead: bool = false

#Thomas: A bool to determine if the player has recently jumped and if they can now wall cling
var can_wall_cling: bool = false

#Thomas: If the player is already wall clinging this determines if they can jump off the wall
var can_wall_jump: bool = false
var consecutive_wall_jumps: int = 0

#Thomas: this will become a move penalty for the player when they equip something
var equipped_item_weight: float = 0
var item_weight_penalty: float = 0

# QOL Feature, allows for easier jump timing when leaving ground
@onready var coyoteTimer: Timer = $CoyoteTimer 
var coyoteJump: bool = false

# EXPERIMENTAL VARIABLES. USE TO TEST FOR NEW CHANGES
@export var impulsive_walljumps: bool = false

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

func _jump() -> void:
	# Determines if player can wall jump
	var walljump: bool = (is_on_wall_only() 
	  and can_wall_cling and consecutive_wall_jumps < MAX_WALLJUMPS)
	if walljump:
		can_wall_cling = false
		if equipped_item == null: #Doing this here so that if you pick something up while wall clinging you'll just fall (but we do need to deactivate wall cling)
			walljumpTimer.start()
			velocity.y = JUMP_VELOCITY / WALLJUMP_FACTOR
			consecutive_wall_jumps += 1
			if(!impulsive_walljumps): return
			if(sprite.flip_h):
				velocity.x += WALLJUMP_IMPULSE
			else:
				velocity.x -= WALLJUMP_IMPULSE
	elif is_on_floor() or coyoteJump:
		velocity.y = JUMP_VELOCITY + abs(item_weight_penalty)
		#Thomas: start a timer here for the wall jump and reset consecutive wall jump counter
		if equipped_item == null:
			walljumpTimer.start()
			consecutive_wall_jumps = 0
	coyoteJump = false

func _start_coyote() -> void:
	coyoteJump = true
	coyoteTimer.start()

# TODO: This method is too long and should probably be reformatted in the future.
func _physics_process(delta: float) -> void:
	if(dead): return
	
	item_weight_penalty = equipped_item_weight/WEIGHT_TO_SPEED_FACTOR
	
	# Reset animations
	if(crouching && Input.is_action_just_released("crouch")):
		uncrouch()
	if(anim.current_animation == "look_up" && Input.is_action_just_released("look_up")):
		anim.current_animation = "idle"
	
	var direction: float = Input.get_axis("move_left", "move_right")
	# Add the gravity and handle jumping animation.
	if not is_on_floor():
		uncrouch() # Can't crouch while airbourne
		if(!(can_wall_cling and is_on_wall_only())):
			if(velocity.y > Y_VEL_ANIM_THRESH):
				anim.play("jump_down")
			elif(velocity.y < -Y_VEL_ANIM_THRESH):
				anim.play("jump_up")
			else:
				anim.play("jump_neutral")
		elif(anim.current_animation != "bump"):
			anim.current_animation = "bump"
		velocity += get_gravity() * delta
	else:
		if(Input.is_action_pressed("crouch") && !direction):
			crouch()
		elif(Input.is_action_just_pressed("look_up")):
			anim.current_animation = "look_up"

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		_jump()
	if Input.is_action_just_pressed("drop_item"):
		unequip()
	
	if direction:
		uncrouch() # Can't crouch while moving
		if(direction < 0):
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		if is_on_floor():
			anim.play("run")
			velocity.x = move_toward(velocity.x, (direction * SPEED) - (item_weight_penalty * direction), GROUND_ACCELERATION)
		else:
			velocity.x = move_toward(velocity.x, (direction * SPEED)  - (item_weight_penalty * direction), AIR_ACCELERATION)
			
		#Thomas: Only let the player wall jump/cling if they're on a wall and haven't just jumped (adjust timer in the walljump timer node)
		if is_on_wall_only() and can_wall_cling and velocity.abs().x > 0:
			velocity.y = move_toward(velocity.y, (SPEED/CLING_FACTOR), GROUND_ACCELERATION)
		
		#Thomas: if the player rleases their wall jump they now have to hit the ground again
		if velocity.abs().x == 0 or is_on_floor():
			can_wall_cling = false
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
	var hit_wall: bool = is_on_wall()
	move_and_slide()
	if(hit_ground != is_on_floor()):
		# Ground has been hit
		if(is_on_floor()):
			anim.current_animation = "idle"
		# Ground has been left
		else:
			_start_coyote()
	# Wall is left, allow coyote jump
	if(hit_wall != is_on_wall()):
		# Wall has been hit
		if is_on_wall():
			# only allow the player to cling for so long
			cling_timer.start()
		# Wall has been left
		else:
			_start_coyote()

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
	# Show ammo counter
	Hud.ammo_counter.visible = true
	#Thomas: WARNING I'm not sure what will happen if the item equipped isn't a gun but hopefully this will prevent any major issues
	# This should work better. Weird solution imo but its what the forums say. -Jay
	if "weight" in item:
		equipped_item_weight = item.weight

# Unequips item
func unequip() -> void:
	if (is_instance_valid(equipped_item)): equipped_item.queue_free()
	Input.set_custom_mouse_cursor(cursors[0], Input.CURSOR_ARROW, Vector2(16, 16))
	# Hide ammo counter
	Hud.ammo_counter.visible = false
	#Thomas: when uneqipping an item set the weight back to nothing
	equipped_item_weight = 0 

func _on_mouse_entered() -> void:
	if(equipped_item != null):
		Input.set_custom_mouse_cursor(cursors[2], Input.CURSOR_ARROW, Vector2(16, 16))

func _on_mouse_exited() -> void:
	if(equipped_item != null):
		Input.set_custom_mouse_cursor(cursors[1], Input.CURSOR_ARROW, Vector2(16, 16))

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if(body.get_collision_layer() == 2):
		die()

#Thomas: this is for signaling when the player is allowed to wall jump (to prevent them from clipping their normal jump)
func _on_walljump_timer_timeout() -> void:
	can_wall_cling = true

func _on_coyote_timer_timeout() -> void:
	coyoteJump = false

func _on_cling_timer_timeout() -> void:
	can_wall_cling = false

## Handles player controls, animations and sound
## Jay Hawkins, Thomas Wilkins

class_name Player
extends CharacterBody2D

# CONSTANTS
## Base player horizontal speed
const SPEED: float = 75.0
## Base vertical velocity given to the player upon jumping
const JUMP_VELOCITY: float = -225.0
## The threshold where the neutral jump animation is played
const Y_VEL_ANIM_THRESH: float = 60 
## Base movement acceleration of player on ground
const GROUND_ACCELERATION: float = 30
## Base frictional deceleration of player on ground
const GROUND_DECELERATION: float = 20
## Base movement acceleration of player in air
const AIR_ACCELERATION: float = 17
## Base frictional deceleration of player in air
const AIR_DECELERATION: float = 8
## Factor that friction increases by when crouched
const CROUCH_FACTOR: float = 2.2
## Thomas: Factor that friction increases by for wall cling
const CLING_FACTOR: float = 4.0
## Thomas: Factor that walljump strength decreases by, this is a divisor for the
## normal jump velocity
const WALLJUMP_FACTOR: float = 1.0
## Jay: The horizontal impulse recieved from walljumping
const WALLJUMP_IMPULSE: float = 150.0
## Thomas: number of times the player can consecutivley wall jump before needing
## to touch the ground
const MAX_WALLJUMPS: int = 3
## Thomas: this is the factor we'll use to divide the equipped items weight into
## a move speed penalty
const WEIGHT_TO_SPEED_FACTOR: float = 1
## The speed at which grip is recovered as % per second
const GRIP_RECOVERY: float = 50
## Multiplies the momentum of the dropped gun
const DROP_MOMENTUM_FACTOR: float = 5

# Static variables
## Array of cursors that respond to gun movement
static var cursors: Array = [
	preload("res://Sprites/UI/crosshair1.png"), # Nothing equipped
	preload("res://Sprites/UI/crosshair2.png"), # Equipped
	preload("res://Sprites/UI/crosshair3.png") # Equipped and over target
]
## Array of sound effects, currently temporary
static var sfx: Dictionary = {
	"death" : preload("res://SFX/Itch/FGHTImpt_Anime Melee 6.wav"),
	"oob_death" : preload("res://SFX/Itch/MAGSpel_Anime Ability Release 10.wav"),
	"jump" : preload("res://SFX/Itch/jump.wav"),
	"land" : preload("res://SFX/Itch/land.wav"),
	"run" : preload("res://SFX/Itch/run.wav")
}
static var skins: Array[Texture] = [
	preload("res://Sprites/Player/Skins/blue_happy.png"),
	preload("res://Sprites/Player/Skins/blue_meh.png"),
	preload("res://Sprites/Player/Skins/blue_neutral.png"),
	preload("res://Sprites/Player/Skins/blue_pissed.png"),
	preload("res://Sprites/Player/Skins/blue_sad.png"),
	preload("res://Sprites/Player/Skins/green_happy.png"),
	preload("res://Sprites/Player/Skins/green_meh.png"),
	preload("res://Sprites/Player/Skins/green_neutral.png"),
	preload("res://Sprites/Player/Skins/green_pissed.png"),
	preload("res://Sprites/Player/Skins/green_sad.png"),
	preload("res://Sprites/Player/Skins/purple_happy.png"),
	preload("res://Sprites/Player/Skins/purple_meh.png"),
	preload("res://Sprites/Player/Skins/purple_neutral.png"),
	preload("res://Sprites/Player/Skins/purple_pissed.png"),
	preload("res://Sprites/Player/Skins/purple_sad.png"),
	preload("res://Sprites/Player/Skins/red_happy.png"),
	preload("res://Sprites/Player/Skins/red_meh.png"),
	preload("res://Sprites/Player/Skins/red_neutral.png"),
	preload("res://Sprites/Player/Skins/red_pissed.png"),
	preload("res://Sprites/Player/Skins/red_sad.png"),
	preload("res://Sprites/Player/Skins/yellow_happy.png"),
	preload("res://Sprites/Player/Skins/yellow_meh.png"),
	preload("res://Sprites/Player/Skins/yellow_neutral.png"),
	preload("res://Sprites/Player/Skins/yellow_pissed.png"),
	preload("res://Sprites/Player/Skins/yellow_sad.png")
]
static var players: Array[Player]

# Exported class variables
@export var oob_death: PackedScene
@export var singleplayerTesting: bool = false
@export var hud: Hud
## Threshold of magnitude of velocity to initiate a wallbounce upon collision
@export var wallbounce_thresh: float = 150
## The threshold of equipped item weight in which you can no longer walljump
@export var wj_weight_threshold: float = 10
## Factor that velocity is multiplied by upon bounce
@export var bounciness: float = 0.45

# EXPERIMENTAL VARIABLES. USE TO TEST FOR NEW CHANGES
@export var impulsive_walljumps: bool = false
@export var rand_skin: bool = true

# Child node references
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var coyoteTimer: Timer = $CoyoteTimer 
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision: CollisionPolygon2D = $EnvironmentalCollision
## Used for looped sounds such as footsteps
@onready var loop_sound: AudioStreamPlayer2D = $LoopingAudio
@onready var death_parts: GPUParticles2D = $DeathParticles
@onready var sprite: Sprite2D = $Sprite2D
@onready var cling_timer: Timer = $ClingTimer
@onready var walljumpTimer: Timer = $WalljumpTimer
@onready var name_display: RichTextLabel = $NameDisplay

# Class variables
# private variables are denoted with an underscore, not all are marked yet
## Thomas: A bool to determine if the player has recently jumped and if they can
## now wall cling
var can_wall_cling: bool = false
## Thomas: If the player is already wall clinging this determines if they can
## jump off the wall
#var can_wall_jump: bool = false
# ^ This wasn't being used anywhere, so I commented it out for now. -Jay
## Number of wall jumps done before touching the ground
var consecutive_wall_jumps: int = 0
## QOL Feature, allows for easier jump timing when leaving ground
var coyoteJump: bool = false
var _crouching: bool = false
var dead: bool = false
var _equipped_item: Node = null
## Thomas: this will become a move penalty for the player when they equip 
## something
var equipped_item_weight: float = 0
var item_weight_penalty: float = 0
## % of grip strength to hold current item
var grip: float = 100

##Thomas: when the gun is fired set this to true to disable the players normal movent (it gets reset to false when they touch the ground)
var projectileMovement : bool = false
var projectileMoveOffset : float = 0
var normalMovement : bool = false
var disableMoveTimer : float = 0 #check this against .1, setting it over in the gun script

# Used for banana, could be used for certain weapon types later.
var stunned: bool = false

# SCORING
var score: int = 0
var player_id: int = 1

# ======================= [ CLASS METHODS ] ====================================

func _enter_tree() -> void:
	if (!singleplayerTesting): set_multiplayer_authority(name.to_int())

## Handles *most* player animations
func _animate() -> void:
	# Reset animations
	if(_crouching && Input.is_action_just_released("crouch")):
		uncrouch()
	if(anim.current_animation == "look_up" && 
	  Input.is_action_just_released("look_up")):
		rpc("updateAnimation", "idle")
	
	if is_on_floor():
		if(Input.is_action_just_pressed("look_up")):
			rpc("updateAnimation", "look_up")
	else:
		uncrouch() # Can't crouch while airbourne
		if(!(can_wall_cling and is_on_wall_only())):
			if(velocity.y > Y_VEL_ANIM_THRESH):
				rpc("playAnimation", "jump_down")
			elif(velocity.y < -Y_VEL_ANIM_THRESH):
				rpc("playAnimation", "jump_up")
				rpc("playAnimation", "jump_neutral")
		elif(anim.current_animation != "bump"):
			rpc("updateAnimation", "bump")

## Handles player entering and exiting ground
func _collide(change_in_ground_state: bool, change_in_wall_state: bool,
  prev_vel: Vector2) -> void:
	# Handle ground collisions and exits
	if(change_in_ground_state):
		# Ground has been hit
		if(is_on_floor()):
			coyoteJump = true
			sound.stream = sfx["land"]
			sound.play()
			if (is_multiplayer_authority()): rpc("updateAnimation", "idle")
			# Ensures accurate resetting of wall jump count
			consecutive_wall_jumps = 0
		# Ground has been left
		elif(coyoteJump): # if statement prevents a sequential coyoteJump after a normal jump
			_start_coyote()
	# Handle wall collisions and exits
	if(change_in_wall_state):
		# Wall has been hit
		if is_on_wall():
			if(prev_vel.length() >= wallbounce_thresh):
				velocity.x = prev_vel.x * -bounciness
			elif can_walljump():
				# only allow the player to cling for so long
				cling_timer.start()
		# Wall has been left
		else:
			_start_coyote()

## Returns whether a player can walljump with currently equipped item
func can_walljump() -> bool:
	return _equipped_item == null || equipped_item_weight < wj_weight_threshold
## Crouching increases "friction" of recoil. Can also be used to drop
## Through platforms in the future.
func crouch() -> void:
	rpc("updateAnimation", "crouch")
	_crouching = true

## Handles player death and animation
## oob: whether or not the player has died from exiting screen bounds
## theta: irrelevant if !oob, angle from boundary center
func die(oob: bool = false, theta: float = 0) -> void:
	if (dead): return
	dead = true
	# Unequip first to prevent weapon going to (0,0)
	unequip()
	# Out of bounds death animation
	if(oob):
		MultiplayerManager.instance.getPlayerData(get_multiplayer_authority()).score -= 1
		DeathMatchGamemode.instance.update_board()
		sound.stream = sfx["oob_death"]
		sound.play()
		var od: Node2D = oob_death.instantiate()
		get_parent().add_child(od)
		od.position = position
		od.rotation = theta
		sprite.visible = false
		position = Vector2(0, 0)
		velocity = Vector2(0, 0)
	else: # Other death animation
		sound.stream = sfx["death"]
		sound.play()
		death_parts.emitting = true
		if (is_multiplayer_authority()): rpc("updateAnimation", "die")
	DeathMatchGamemode.instance.update_board()
	
	collision.disabled = true
	await get_tree().create_timer(3).timeout
	# Respawn
	# Changed to reset manually as to not crash multiplayer
	collision.disabled = false
	if (is_multiplayer_authority()): rpc("updateAnimation", "idle")
	position = Map.current_map.getRandomSpawn()
	velocity = Vector2(0, 0)
	dead = false
	sprite.visible = true
	
	$Hurtbox.monitoring = false
	modulate = Color(0.8, 0.8, 0.8, 0.8)
	
	await get_tree().create_timer(1.5).timeout
	cancel_iframes()

## Turns off invincibility
func cancel_iframes() -> void:
	modulate = Color(1, 1, 1, 1)
	$Hurtbox.monitoring = true

## Called on item pickup. Equips node item.
func equip(scene: PackedScene, gun_resource: GunResource, 
 	  ammo: int = gun_resource.maxAmmo) -> void:
	unequip()
	if (!is_multiplayer_authority()): return
	var item: Node = scene.instantiate()
	item.name = name
	item.gun_resource = gun_resource
	_equipped_item = item
	Input.set_custom_mouse_cursor(cursors[1], Input.CURSOR_ARROW, Vector2(16, 16))
	if item is Gun:
		equipped_item_weight = item.weight
		item.ammo = ammo
	# Show ammo counter
	hud.ammo_counter.visible = true
	hud.grip_bar.visible = true
	item.hud = self.hud
	
	add_child(item)

# Unequips item
func unequip() -> void:
	if (!is_multiplayer_authority()): return
	# Spawn dropped item if there's still ammo.
	if (_equipped_item is Gun && _equipped_item.ammo > 0):
		# If lost due to grip, the dropped item will launch where player is
		# being knocked back.
		var momentum: Vector2 = Vector2.ZERO
		momentum = velocity * DROP_MOMENTUM_FACTOR
		if(grip < 0):
			momentum = momentum * -grip
		_equipped_item.drop(momentum)
	if (is_instance_valid(_equipped_item)): 
		_equipped_item.free()
	_equipped_item = null
	Input.set_custom_mouse_cursor(cursors[0], Input.CURSOR_ARROW, Vector2(16, 16))
	# Hide ammo counter
	hud.ammo_counter.visible = false
	hud.grip_bar.visible = false
	#Thomas: when uneqipping an item set the weight back to nothing
	equipped_item_weight = 0
	

func _grip_process(delta: float) -> void:
	if grip <= 0:
		unequip()
		grip = 100
		return
	grip += GRIP_RECOVERY * delta
	if(grip > 100):
		grip = 100
	hud.update_grip(grip)

func _jump() -> void:
	# Determines if player can wall jump
	var walljump: bool = (is_on_wall_only() 
	  and can_wall_cling and consecutive_wall_jumps < MAX_WALLJUMPS)
	if walljump:
		sound.stream = sfx["jump"]
		sound.play()
		can_wall_cling = false
		#Doing this here so that if you pick something up while wall clinging you'll just fall (but we do need to deactivate wall cling)
		if can_walljump(): 
			walljumpTimer.start()
			velocity.y = JUMP_VELOCITY / WALLJUMP_FACTOR
			consecutive_wall_jumps += 1
			if(!impulsive_walljumps): 
				return
			if(sprite.flip_h):
				velocity.x += WALLJUMP_IMPULSE
			else:
				velocity.x -= WALLJUMP_IMPULSE
	elif is_on_floor() or coyoteJump:
		sound.stream = sfx["jump"]
		sound.play()
		velocity.y = JUMP_VELOCITY + abs(item_weight_penalty)
		# Thomas: start a timer here for the wall jump and reset consecutive 
		# wall jump counter
		if can_walljump():
			walljumpTimer.start()
			consecutive_wall_jumps = 0
	coyoteJump = false

func _move(direction: float, delta: float) -> void:
	if direction and disableMoveTimer <= 0:
		uncrouch() # Can't crouch while moving
		if(direction < 0):
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		if is_on_floor():
			projectileMovement = false
			projectileMoveOffset = 0
			rpc("playAnimation", "run")
			if(!loop_sound.playing):
				loop_sound.stream = sfx["run"]
				loop_sound.play()
			velocity.x = move_toward(velocity.x + projectileMoveOffset*delta, (direction * SPEED) - (item_weight_penalty * direction), GROUND_ACCELERATION - projectileMoveOffset*delta*direction)
		else:
			if projectileMovement == false or normalMovement:
				velocity.x = move_toward(velocity.x, (direction * SPEED) - (item_weight_penalty * direction), AIR_ACCELERATION)
			else:
				velocity.x = move_toward(velocity.x + projectileMoveOffset*delta, (direction * SPEED) - (item_weight_penalty * direction), AIR_ACCELERATION - projectileMoveOffset*delta*direction) #TODO: need to test this more but I think it works
			
		#Thomas: Only let the player wall jump/cling if they're on a wall and haven't just jumped (adjust timer in the walljump timer node)
		if is_on_wall_only() and can_wall_cling and velocity.abs().x > 0:
			velocity.y = move_toward(velocity.y, (SPEED/CLING_FACTOR), GROUND_ACCELERATION)
		
		#Thomas: if the player rleases their wall jump they now have to hit the ground again
		if velocity.abs().x == 0 or is_on_floor():
			can_wall_cling = false
	else:
		if(is_on_floor()):
			if(anim.current_animation != "crouch" && anim.current_animation != "look_up"):
				rpc("updateAnimation", "idle")
			var dec: float = GROUND_DECELERATION
			if(_crouching):
				dec *= CROUCH_FACTOR
			velocity.x = move_toward(velocity.x, 0, dec)
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_DECELERATION)

func _start_coyote() -> void:
	coyoteJump = true
	coyoteTimer.start()

func uncrouch() -> void:
	_crouching = false
	if(is_on_floor() && velocity.x == 0):
		rpc("updateAnimation", "idle")

func stun(time: float) -> void:
	stunned = true
	sprite.modulate = Color(.8, .8, .8)
	anim.play("crouch")
	await get_tree().create_timer(time).timeout
	stunned = false
	sprite.modulate = Color.WHITE

# =========================== [ SIGNALS ] ======================================

func _physics_process(delta: float) -> void:
	if(dead || !is_multiplayer_authority()): return
	item_weight_penalty = equipped_item_weight / WEIGHT_TO_SPEED_FACTOR
	_animate()
	var direction: float = Input.get_axis("move_left", "move_right")
	# Add the gravity and handle jumping animation.
	if not is_on_floor():
		uncrouch() # Can't crouch while airbourne
		velocity += get_gravity() * delta
	else:
		if(Input.is_action_pressed("crouch") && !direction):
			crouch()

	if disableMoveTimer > 0:
		disableMoveTimer -= delta
	
	if(!stunned):
		_move(direction, delta)
	_grip_process(delta)

	var hit_ground: bool = is_on_floor()
	var hit_wall: bool = is_on_wall()
	var pre_collision_vel: Vector2 = velocity
	move_and_slide()
	# != conditions help detect a change in state before and after moving.
	# Godot doesn't have the collision signals that unity has, so this
	# is my solution. -Jay
	_collide(hit_ground != is_on_floor(), hit_wall != is_on_wall(),
	  pre_collision_vel)
	
	if Input.is_action_just_pressed("jump") && !stunned:
		_jump()
	if Input.is_action_just_pressed("drop_item"):
		unequip()
	if Input.is_action_just_pressed("ToggleMoveTypes"): #TODO: this is for testing purposes, probably want to remove it later
		normalMovement = !normalMovement
	if Input.is_action_just_pressed("show_names"):
		for p: Player in players:
			p.name_display.visible = true
	elif Input.is_action_just_released("show_names"):
		for p: Player in players:
			p.name_display.visible = false
	

func _ready() -> void:
	name_display.text = MultiplayerManager.instance.getPlayerData(get_multiplayer_authority()).username
	# This should probably sync with server, but idk how. - Jay
	players.append(self)
	player_id = players.size()
	# Randomize skin
	if(rand_skin):
		sprite.texture = skins[randi() % skins.size()]
	else:
		var data: PlayerData = get_node("/root/Root/MultiplayerManager/%s" % name)
		sprite.texture = skins[(data.color * 5) + data.emotion]
	if (!is_multiplayer_authority()): return
	if (singleplayerTesting): 
		print("Singleplayer testing")
		hud = $/root/Map/CanvasLayer/PlayerHud
	else: 
		print("Multiplayer")
		hud = $/root/Root/Map/CanvasLayer/PlayerHud
	rpc("playAnimation", "idle")
	# Add to dynamic camera points
	DynamicCamera.instance.pois.append(self)
	# Set initial spawn point
	position = Map.current_map.getRandomSpawn()

func _on_mouse_entered() -> void:
	if(_equipped_item != null):
		Input.set_custom_mouse_cursor(cursors[2], Input.CURSOR_ARROW, Vector2(16, 16))

func _on_mouse_exited() -> void:
	if(_equipped_item != null):
		Input.set_custom_mouse_cursor(cursors[1], Input.CURSOR_ARROW, Vector2(16, 16))

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if (dead): return
	if(body.get_collision_layer() == 2):
		DeathMatchGamemode.instance.update_board()
		call_deferred("die")
		# Add to other player score if killed. Subtract if killed by self
		if body is Projectile:
			var pd: PlayerData = MultiplayerManager.instance.getPlayerData(body.shot_by)
			if(pd != null):
				pd.score += 1
				pd.totalKills += 1
			if(body.one_in_chamber):
				if(body.shot_by_gun != null):
					body.shot_by_gun.reload()
		else:
			MultiplayerManager.instance.getPlayerData(get_multiplayer_authority()).score -= 1

#Thomas: this is for signaling when the player is allowed to wall jump (to prevent them from clipping their normal jump)
func _on_walljump_timer_timeout() -> void:
	can_wall_cling = true

func _on_coyote_timer_timeout() -> void:
	coyoteJump = false

func _on_cling_timer_timeout() -> void:
	can_wall_cling = false

@rpc("call_local")
func updateAnimation(animation: String) -> void:
	anim.current_animation = animation

@rpc("call_local")
func playAnimation(animation: String) -> void:
	anim.play(animation)

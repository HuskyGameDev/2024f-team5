extends RigidBody2D

# Amount that the projectile effects the grip of the player
@export var damage: float = 30
# Amount of knockback that player recieves on collision
@export var knockback: float = 20
@export var delete_on_collide: bool = true
## Enable/disable bullet trail visual
@export var melee: bool = false
## Line representing the bullet-trail visual
@onready var trail: Line2D
## Determines the "section of time" that the bullet trail represents
@export var trail_period: float = 1
## Prevents bullets from going on forever.
@export var timeout: float = 3
@onready var timer: Timer = $Timer
var init_pos: Vector2
var shot_by: Node

func _on_body_entered(body: Node) -> void:
	if(delete_on_collide && body != shot_by):
		queue_free()

func _ready() -> void:
	if(!melee):
		trail = $Line2D
	timer.wait_time = timeout
	timer.start()
	init_pos = global_position

func _process(delta: float) -> void:
	if(trail != null): _trail()

## Handles bullet trail
func _trail() -> void:
	var target_length: float = linear_velocity.length() * trail_period
	if(trail.points[0].x > -target_length):
		trail.points[0] = to_local(init_pos)
	else:
		trail.points[0] = Vector2(-target_length, 0)
	trail.points[0].x = clamp(trail.points[0].x,
	  -target_length, -3)

func _on_timer_timeout() -> void:
	queue_free()

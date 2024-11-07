extends RigidBody2D

# Amount that the projectile effects the grip of the player
@export var damage: float = 30
# Amount of knockback that player recieves on collision
@export var knockback: float = 20
@export var delete_on_collide: bool = true
## Line representing the bullet-trail visual
@onready var trail: Line2D = $Line2D
## Determines the "section of time" that the bullet trail represents
@export var trail_period: float = 1
## Prevents bullets from going on forever.
@export var timeout: float = 3
## The amount of time it takes for the trail to grow to full size
# this is a pretty buggy means to an end, but it works if the values
# correspond to bullet velocity well. Maybe derive this mathematically.
@export var trail_grow_rate: float = 1
@onready var timer: Timer = $Timer

func _on_body_entered(body: Node) -> void:
	if(delete_on_collide):
		queue_free()

func _ready() -> void:
	timer.wait_time = timeout

func _process(delta: float) -> void:
	# Handle bullet trail
	if(trail.points[0].x > -linear_velocity.length() * trail_period):
		trail.points[0].x -= linear_velocity.length() * (delta / trail_grow_rate)
	trail.points[0].x = clamp(trail.points[0].x,
	  -linear_velocity.length() * trail_period, -3)


func _on_timer_timeout() -> void:
	queue_free()

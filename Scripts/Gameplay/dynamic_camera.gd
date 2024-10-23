## Moves camera to average point between many points of interest
## Jay Hawkins
extends Camera2D

# The factor at which distance affects camera speed
@export var smoothing: float = 1
@export var pois: Array[Node2D]
# The distance at which the camera should stop before a border
@export var limit_padding:float = 30
@export var north_border: Node2D
@export var west_border: Node2D
@export var east_border: Node2D
@export var south_border: Node2D

# Sets camera boundaries based off borders
func _ready() -> void:
	if(north_border == null || west_border == null || east_border == null || 
	  south_border == null):
		print("One or more borders not assigned to camera.")
		return
	limit_top = north_border.global_position.y + limit_padding
	limit_left = west_border.global_position.x + limit_padding
	limit_right = east_border.global_position.x - limit_padding
	limit_bottom = south_border.global_position.y - limit_padding

# Moves camera
func _process(delta: float) -> void:
	var goal: Vector2 = _avg_between_pois()
	var dist: float = position.distance_to(goal)
	position = position.move_toward(goal, dist * delta / smoothing)

func _avg_between_pois() -> Vector2:
	var sum: Vector2 = Vector2(0, 0)
	for p: Node2D in pois:
		sum += p.position
	return sum / pois.size()

## Moves camera to average point between many points of interest
## Jay Hawkins
extends Camera2D
class_name  DynamicCamera

static var instance: DynamicCamera

# The factor at which distance affects camera speed
@export var smoothing: float = 1
@export var pois: Array[Node2D]
## Enable/Disable the dynamic zoom
@export var dynamic_zoom: bool = true
## The distance at which the camera should start zooming out
@export var dist_thresh: float = 50
@export var min_zoom: float = 1.3
@export var max_zoom: float = 2
## The amount that zoom changes with each unit of distance
@export var zoom_slope: float = .0025
# The distance at which the camera should stop before a border
@export var limit_padding:float = 30
@export var north_border: Node2D
@export var west_border: Node2D
@export var east_border: Node2D
@export var south_border: Node2D

# Sets camera boundaries based off borders
func _ready() -> void:
	instance = self
	if(north_border == null || west_border == null || east_border == null || 
	  south_border == null):
		print("One or more borders not assigned to camera.")
		return
	limit_top = int(north_border.global_position.y + limit_padding)
	limit_left = int(west_border.global_position.x + limit_padding)
	limit_right = int(east_border.global_position.x - limit_padding)
	limit_bottom = int(south_border.global_position.y - limit_padding)
	zoom = Vector2(max_zoom, max_zoom)

# Moves camera
func _process(delta: float) -> void:
	# POSITION
	var goal: Vector2 = _avg_between_pois()
	var dist: float = position.distance_to(goal)
	position = position.move_toward(goal, dist * delta / smoothing)
	# ZOOM
	if(dynamic_zoom): _dynamic_zoom()
	

func _dynamic_zoom() -> void:
	var stretch: float = position.distance_to(pois[0].position)
	if(stretch > dist_thresh):
		var newZoom : float = max_zoom - (stretch - dist_thresh) * zoom_slope
		newZoom = clamp(newZoom, min_zoom, max_zoom)
		zoom = Vector2(newZoom, newZoom)

func _avg_between_pois() -> Vector2:
	var sum: Vector2 = Vector2(0, 0)
	for p: Node2D in pois:
		sum += p.position
	return sum / pois.size()

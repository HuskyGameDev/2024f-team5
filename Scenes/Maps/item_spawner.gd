extends Node2D


var items_to_spawn: Variant = []
@export var spawn_timer: float = 20.0

# Other approach. Same item every time
@export var random_item: bool = true
@export var gun_resource: GunResource
@export var spawn_obj: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	items_to_spawn.append(load("res://Scenes/Objects/pistol_pickup.tscn"))
	items_to_spawn.append(load("res://Scenes/Objects/el_dante_pickup.tscn"))
	spawn_random_item()
	_start_timer()
	
func _start_timer() -> void:
	var timer: Timer = Timer.new()
	timer.wait_time = spawn_timer
	timer.timeout.connect(_on_Timer_Timeout)
	add_child(timer)
	timer.start()
	
func _on_Timer_Timeout() -> void:
	if (get_children().size() == 1):
		if(random_item):
			spawn_random_item()
		else:
			spawn_item()

func spawn_random_item() -> void:
	var random_index: int = randi() % items_to_spawn.size()
	var item_scene: Variant = items_to_spawn[random_index]
	var item_instance: Variant = item_scene.instantiate()
	add_child(item_instance)

func spawn_item() -> void:
	var item_instance: Variant = spawn_obj.instantiate()
	item_instance.gun_resource = gun_resource
	add_child(item_instance)

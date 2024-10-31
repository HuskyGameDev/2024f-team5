extends Node2D


var items_to_spawn: Variant = []
var spawn_timer: float = 10.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	items_to_spawn.append(load("res://Demo/scenes/gun_pickup.tscn"))
	_start_timer()
	
func _start_timer() -> void:
	var timer: Timer = Timer.new()
	timer.wait_time = spawn_timer
	timer.timeout.connect(_on_Timer_Timeout)
	add_child(timer)
	timer.start()
	
func _on_Timer_Timeout() -> void:
	spawn_random_item()

func spawn_random_item() -> void:
	var random_index: int = randi() % items_to_spawn.size()
	var item_scene: Variant = items_to_spawn[random_index]
	var item_instance: Variant = item_scene.instantiate()
	add_child(item_instance)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

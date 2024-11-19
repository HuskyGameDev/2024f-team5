class_name FPSCounter extends CanvasLayer

@export var refreshRate: float = 0.5
@export var memorySize: int = 60

@onready var label: RichTextLabel = $RichTextLabel
@onready var timer: Timer = $Timer

enum CounterState{
	OFF,
	SIMPLE,
	ADVANCED
}

var state: CounterState = CounterState.OFF
var framerates: Array[float]
var end: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	framerates.resize(memorySize)
	timer.start()

func setState(newState: CounterState) -> void:
	state = newState
	if (state == CounterState.OFF): hide()
	else: show()

func _on_timer_timeout() -> void:
	framerates[end] = Engine.get_frames_per_second()
	end += 1
	if (end > memorySize - 1): end = 0
	match (state):
		CounterState.OFF:
			return
		CounterState.SIMPLE:
			label.text = "FPS: %s" % Engine.get_frames_per_second()
		CounterState.ADVANCED:
			label.text = "FPS: %s  |  Average: %s  |  Max: %s  |  Min: %s" % [Engine.get_frames_per_second(), average(framerates), framerates.max(), framerates.min()]
	timer.start()

func average(arr: Array[float]) -> float:
	var total: float
	for num: float in arr:
		total += num
	return roundf(total / arr.size())

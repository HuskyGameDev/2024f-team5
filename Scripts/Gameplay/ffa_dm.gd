extends Label

@onready var timer: Timer = $Timer
@onready var lbDisplay: Label = $Leaderboard
var leaderboard: Array[Player]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "%d:%02d" % [floor(timer.time_left / 60), int(timer.time_left) % 60]
	# should update upon death, not every frame. Will fix later.
	update_board()

func update_board() -> void:
	if (!is_multiplayer_authority()): return
	var text: String = ""
	for p: Player in Player.players:
		text += "Player %d: %d kills\n" % [p.player_id, p.score]
	lbDisplay.text = text

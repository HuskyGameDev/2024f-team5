extends Label
class_name DeathMatchGamemode

static var instance: DeathMatchGamemode

@onready var timer: Timer = $Timer
@onready var lbDisplay: Label = $Leaderboard
@onready var winDisplay: Label = $WinnerDisplay
var leaderboard: Array[Player]
var winning: Player

func _ready() -> void:
	instance = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	text = "%d:%02d" % [floor(timer.time_left / 60), int(timer.time_left) % 60]

func update_board() -> void:
	if (!is_multiplayer_authority()): return
	var sb_text: String = "" #scoreboard text
	var top_score: int = -1
	for p: Player in Player.players:
		if(p.score > top_score):
			winning = p
			sb_text += "WINNING"
		sb_text += "Player %d: %d kills\n" % [p.player_id, p.score]
	lbDisplay.text = sb_text


func _on_timer_timeout() -> void:
	get_tree().paused = true
	if(winning == null):
		winDisplay.text = "TIE GAME"
	else:
		winDisplay.text = "WINNER: P%d" % [winning.player_id]
	winDisplay.visible = true
	await get_tree().create_timer(5).timeout
	# TODO: GO TO LOBBY
	MultiplayerManager.instance.leaveServer()

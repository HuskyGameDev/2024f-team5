extends Label
class_name DeathMatchGamemode

static var instance: DeathMatchGamemode

@onready var timer: Timer = $Timer
@onready var lbDisplay: Label = $Leaderboard
@onready var winDisplay: Label = $WinnerDisplay
@onready var scoreEntry: PackedScene = load("res://Scenes/UI/ScoreboardEntry.tscn")
@onready var data: Node = $Data

var leaderboard: Array[Player]
var winning: ScoreboardEntry

func _ready() -> void:
	instance = self
	for data: PlayerData in MultiplayerManager.instance.get_children():
		print("Add board")
		var entry: ScoreboardEntry = scoreEntry.instantiate()
		entry.name = str(data.uuid)
		data.add_child(entry)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	text = "%d:%02d" % [floor(timer.time_left / 60), int(timer.time_left) % 60]

func update_board() -> void:
	if (!is_multiplayer_authority()): return
	var sb_text: String = "" #scoreboard text
	var top_score: int = -1
	for score: ScoreboardEntry in data.get_children():
		if(score.score > top_score):
			winning = score
			top_score = score.score
			sb_text += "WINNING "
		sb_text += "%s: %d kills\n" % [score.user, score.score]
	lbDisplay.text = sb_text

func _on_timer_timeout() -> void:
	get_tree().paused = true
	if(winning == null):
		winDisplay.text = "TIE GAME"
	else:
		winDisplay.text = "WINNER: P%d" % [winning.player_id]
	winDisplay.visible = true
	await get_tree().create_timer(5).timeout
	
	get_tree().paused = false
	var lobby: Lobby = load("res://Scenes/Menus/Lobby.tscn").instantiate()
	lobby.isAdmin = MultiplayerManager.instance.hosting
	lobby.data = MultiplayerManager.instance.data
	$/root/Root.add_child(lobby)
	$/root/Root/Map.queue_free()

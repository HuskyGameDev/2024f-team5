extends Control
class_name DeathMatchGamemode

static var instance: DeathMatchGamemode

@onready var timer: Timer = $Timer
@onready var lbDisplay: Label = $Leaderboard
@onready var winDisplay: RichTextLabel = $WinnerDisplay
@onready var timerDisplay: Label = $TimerDisplay

var leaderboard: Array[Player]
var winning: PlayerData
var winners: int = 0

func _ready() -> void:
	instance = self
	update_board()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	timerDisplay.text = "%d:%02d" % [floor(timer.time_left / 60), int(timer.time_left) % 60]

func update_board() -> void:
	var sb_text: String = "" #scoreboard text
	var top_score: int = -1
	for data: PlayerData in MultiplayerManager.instance.get_children():
		if(data.score > top_score):
			winning = data
			top_score = data.score
			winners = 1
		elif (data.score == top_score):
			winners += 1
		sb_text += "%s: %d kills\n" % [data.username, data.score]
	lbDisplay.text = sb_text

func _on_timer_timeout() -> void:
	if(winners > 1):
		winDisplay.text = "[center][b]TIE GAME[/b][/center]"
	else:
		winDisplay.text = "[center][b]WINNER: %s[/b][/center]" % [winning.username]
		if (MultiplayerManager.instance.hosting): winning.wins += 1
	winDisplay.show()
	get_tree().paused = true
	await get_tree().create_timer(5).timeout
	
	get_tree().paused = false
	for data: PlayerData in MultiplayerManager.instance.get_children():
		data.score = 0
	var lobby: Lobby = load("res://Scenes/Menus/Lobby.tscn").instantiate()
	lobby.isAdmin = MultiplayerManager.instance.hosting
	lobby.data = MultiplayerManager.instance.data
	$/root/Root.add_child(lobby)
	$/root/Root/Map.queue_free()

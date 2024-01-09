extends CanvasLayer

@onready var score_label = %ScoreLabel
@onready var lives_label = %LivesLabel
@onready var level_label = %LevelLabel
@onready var game_over_label = %GameOverLabel
@onready var level_won_label = %LevelWonLabel

func _ready():
	game_over_label.hide()
	level_won_label.hide()
	Globals.update_ui.connect(update)
	update()


func update():
	score_label.text = str(Globals.score)
	lives_label.text = str(Globals.lives)
	level_label.text = str(Globals.level)

func show_game_over():
	game_over_label.show()

func show_level_won():
	level_won_label.show()

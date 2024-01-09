extends Node

var player_pos: Vector2

signal update_ui
signal game_over

var is_game_over: bool = false

var last_score: int = 0
var score: int = 0:
	set(value):
		score = value
		update_ui.emit()

var lives:int = 2:
	set(value):
		if value < 0:
			game_over.emit()
			is_game_over = true
		else:
			lives = value
			update_ui.emit()


var level: int = 1:
	set(value):
		level = value
		update_ui.emit()

func reset():
	level = 1
	lives = 2
	score = 0
	last_score = 0

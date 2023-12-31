extends Node

const MAX_PLAYER_LIFE: int = 3

var current_player_life: int = 0
var game_started: bool = false

func game_start():
	reset_life()
	game_started = true

func reset_life():
	current_player_life = MAX_PLAYER_LIFE

func lose_life():
	current_player_life -= 1
	if game_started and current_player_life <= 0:
		game_over()

func game_over():
	get_tree().change_scene_to_file("res://sources/scenes/game_over.tscn")
	game_started = false

extends Node

func start_boss(body):
	if body.is_in_group("player"):
		get_tree().get_first_node_in_group("boss").enable()
	$Music.stream = preload("res://assets/Screws_Loose_Oh_No_Now_Theres_A_Boss_-_Loop.ogg")
	$Music.play()

func boss_killed():
	get_tree().change_scene_to_file("res://sources/scenes/win_screen.tscn")

extends Node

func _ready() -> void:
	await $Music.finished
	$Music.stream = preload("res://assets/Screws_Loose_Oh_No_How_Could_This_Happen_-_Loop.ogg")
	$Music.play()

func start_boss(body):
	if body.is_in_group("player"):
		get_tree().get_first_node_in_group("boss").enable()
	$Music.stream = preload("res://assets/Screws_Loose_Oh_No_Now_Theres_A_Boss_-_Opening (1).ogg")
	$Music.play()
	GameManage.reset_life()
	$Field/BossTrigger/Shape.set_deferred("disabled", true)
	await $Music.finished
	$Music.stream = preload("res://assets/Screws_Loose_Oh_No_Now_Theres_A_Boss_-_Loop.ogg")
	$Music.play()

func boss_killed():
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://sources/scenes/win_screen.tscn")

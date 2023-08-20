extends Control

@onready var play_music = $MainMenuMusic

func _ready() -> void:
	play_music.play()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://sources/scenes/real_level.tscn")
	hide()

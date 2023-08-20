extends Control

@onready var play_music = $MainMenuMusic
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_music.play()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://sources/scenes/real_level.tscn")
	hide()
	pass # Replace with function body.

#func _on_quite_pressed() -> void:
#	get_tree().quit()
#	pass # Replace with function body.

extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GameOverMusic.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://sources/scenes/title_screen.tscn")
	hide() # Repl
	pass # Replace with function body.

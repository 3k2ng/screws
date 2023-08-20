extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func _process(delta):
	pass

func _on_resume_pressed():
	get_tree().paused = false
	hide()

extends StaticBody2D

@onready var opened = false

func _process(delta):
	if opened:
		return
	for button in get_tree().get_nodes_in_group("Button"):
		if not button.pressed:
			return
	opened = true
	$AnimationPlayer.play("open")
	$CollisionShape2D.disabled = true

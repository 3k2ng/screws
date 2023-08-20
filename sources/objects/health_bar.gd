extends HBoxContainer

const HEART_RECT: PackedScene = preload("res://sources/objects/heart.tscn")

func _process(delta):
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for i in GameManage.current_player_life:
		add_child(HEART_RECT.instantiate())

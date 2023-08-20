extends Node

func start_boss(body):
	if body.is_in_group("player"):
		get_tree().get_first_node_in_group("boss").enable()

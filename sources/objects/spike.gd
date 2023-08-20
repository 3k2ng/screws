extends Node2D

@onready var player_node = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.th function body.

func _ready() -> void:
	GameManage.game_start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_area_2d_body_entered(body):
	if body == player_node:
		GameManage.game_over()
	pass # Replace with function ity.x)body.

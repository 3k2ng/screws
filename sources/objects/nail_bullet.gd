extends Node2D

var direction = 0
@onready var player_node = get_tree().get_first_node_in_group("player")
var speed = 20
var cur_speed = speed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if cur_speed != speed:
		self.visible = false

	if self.visible == true:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2((speed * direction), 0))
		query.exclude = [self, player_node]
		var result = space_state.intersect_ray(query)
		
		
		if not result.is_empty():
			cur_speed = self.position.distance_to(result.position)
	
	position.x += cur_speed * direction

	pass


func _on_area_2d_area_entered(area):
	pass # Replace with function body.
	
func set_direction(dir):
	direction = dir


func _on_area_2d_body_entered(body):
	if body.has_method("on_shot"):
		body.on_shot()
	self.queue_free()
	pass # Replace with function body.

extends Node2D

var direction = 0
@onready var player_node = get_tree().get_first_node_in_group("player")
var speed = 2000
var cur_speed = speed
var lifetime = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if lifetime <= 0:
		self.queue_free()
	lifetime -= delta
	
	$RayCast2D.target_position.x = (cur_speed + 16) * direction * delta
	
	if $RayCast2D.is_colliding():
		print(self.global_position.distance_to($RayCast2D.get_collision_point()))
		
		var body = $RayCast2D.get_collider()
		
		if body.has_method("on_shot"):
			body.on_shot()
		self.queue_free()
	
	position.x += cur_speed * direction * delta + 1

func _on_area_2d_area_entered(area):
	pass # Replace with function body.
	
func set_direction(dir):
	direction = dir

func _on_area_2d_body_entered(body):
	if body.has_method("on_shot"):
		body.on_shot()
	self.queue_free()
	pass # Replace with function body.

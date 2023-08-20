extends Node2D

var dir = Vector2(0,0)

func _process(delta):
	self.position += dir * delta * 300
	pass


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.hit(100 * dir.x/abs(dir.x))
		self.queue_free()
	pass # Replace with function body.

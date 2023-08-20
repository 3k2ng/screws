extends Node2D

var vy = -400
var dir = 1

func _process(delta):
	position.y += vy * delta
	vy += 512 * 2 * delta
	
	if vy > 400:
		self.queue_free()
		
	


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.hit(400*dir)
	pass # Replace with function body.

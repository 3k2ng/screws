extends Node2D


var velocity:Vector2 = Vector2(0,-100)
var maxlifetime = 10
var lifetime = maxlifetime
# Called when the node enters the scene tree for the first time.

func _ready():
	
	var angle = deg_to_rad(randf_range(-20, 20) - 90)
			
	var dir = Vector2(cos(angle), sin(angle))
	
	velocity.x = dir.x * 100
	velocity.y = dir.y * 1200
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(lifetime)
	position.x += velocity.x * delta
	position.y += velocity.y * delta
	
	velocity.y += 512 * delta
	lifetime -= delta
	
	if lifetime <= 0 || self.position.y > 1920:
		self.queue_free()
		
	$Sprite2D.look_at(Vector2(velocity.x,velocity.y))

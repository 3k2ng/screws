extends Node2D


var velocity:Vector2 = Vector2(0,-100)
var maxlifetime = 20
var lifetime = maxlifetime
var bsp
# Called when the node enters the scene tree for the first time.

func _ready():
	
	var angle = deg_to_rad(randf_range(-30, 30) - 90)
			
	var dir = Vector2(cos(angle), sin(angle))
	
	velocity.x = dir.x * randi_range(50,200)
	velocity.y = dir.y * 2000
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(lifetime)
	position.x += velocity.x * delta
	position.y += velocity.y * delta
	
	if velocity.y < 20 && velocity.y > -20:
		self.position.x = randi_range(bsp.x - 128*4, bsp.x + 128*4)
		velocity.x = 0
		
	if velocity. y < 300:
		velocity.y += 2000 * delta
	lifetime -= delta
	
	
	
	if lifetime <= 0 || self.position.y > 1920:
		self.queue_free()
		
	$Sprite2D.look_at(Vector2(velocity.x * 10,velocity.y * 10))

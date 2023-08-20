extends Node2D

var velocity:Vector2 = Vector2(0,-100)
var maxlifetime = 0.5
var lifetime = maxlifetime

func set_dir(dir):
	velocity.x = dir.x * RandomNumberGenerator.new().randi_range(80,150)
	velocity.y = dir.y * RandomNumberGenerator.new().randi_range(80,150)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(lifetime)
	position.x += velocity.x * delta
	position.y += velocity.y * delta
	
	velocity.y += 512 * delta
	lifetime -= delta
	
	if lifetime <= 0:
		self.queue_free()
		
	$Sprite2D.rotate(velocity.x/10 * delta)
	$Sprite2D.modulate.a = lifetime/maxlifetime
	
	
	pass

extends Node2D
var vy = -1000
var vx = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	vy += 512 * delta
	position.y += vy * delta
	position.x += vx * delta
	pass

extends Node2D

var dir = Vector2(0,0)

func _process(delta):
	self.position += dir * delta * 300
	pass

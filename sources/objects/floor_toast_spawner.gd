extends Node2D

var spawn_delay_timer = 0.05
var spawn_delay = 0.05
var gap = 8

@onready var floor_toast = preload("res://sources/objects/floor_toast.tscn")

var leftx
var rightx

func spawn_floor_toast():
	var ntoast = floor_toast.instantiate()
	ntoast.position = self.position
	ntoast.dir = gap/abs(gap)
	self.get_parent().add_child(ntoast)

func _process(delta):
	
	self.position.x += gap
	
	if spawn_delay_timer >= 0:
		spawn_delay_timer -= delta
	else: 
		spawn_delay_timer = spawn_delay
		spawn_floor_toast()
	
	if self.position.x > rightx || self.position.x < leftx:
		self.queue_free()

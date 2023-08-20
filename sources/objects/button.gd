extends Node2D

@export var wire:TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("unhit")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func press():
	if wire:
		wire.modulate.r = 1
		wire.modulate.g = 1
		wire.modulate.b = 1
	$AnimatedSprite2D.play("hit")

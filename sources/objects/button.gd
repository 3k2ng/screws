extends Node2D

@export var wire: TileMap

@onready var pressed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("unhit")

func press():
	if wire:
		wire.modulate.r = 1
		wire.modulate.g = 1
		wire.modulate.b = 1
	$AnimatedSprite2D.play("hit")
	pressed = true

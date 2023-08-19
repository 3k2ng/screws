extends CharacterBody2D

@export var movement_speed: float = 128
@export var moving_distance: float = 512

@onready var start_point: float = global_position.x
@onready var end_point: float = global_position.x + moving_distance

@onready var is_moving_right = true

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = movement_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(delta):
	if position.x >= end_point:
		is_moving_right = false
	elif position.x <= start_point:
		is_moving_right = true
	if is_moving_right:
		velocity.x = movement_speed
	else:
		velocity.x = -movement_speed
	if not is_on_floor():
		velocity.y += 512 * delta
	move_and_slide()
	

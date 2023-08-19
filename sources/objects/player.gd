extends CharacterBody2D



@export var movement_speed_blocks: float
@export var jump_height_blocks : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float

@onready var block_size:int = 128

@onready var jump_height = jump_height_blocks * block_size
@onready var movement_speed = movement_speed_blocks * block_size

@onready var jump_velocity = float ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity = float ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity = float ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0


var can_jump:bool = false

var on_jump_timer:float = 0
@export var on_jump_timer_max:float 

var coyote_timer:float = 0
@export var coyote_timer_max:float

func _ready():
	pass

func _physics_process(delta):
	# Add the gravity.
	
	if not is_on_floor():
		if velocity.y < 0:
			velocity.y += jump_gravity*delta
		else:
			velocity.y += fall_gravity*delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept"):
		on_jump_timer = on_jump_timer_max
	if Input.is_action_just_released("ui_accept"):
		if velocity.y < 0:
			velocity.y = 0
		
	if is_on_floor():
		coyote_timer = coyote_timer_max
	else:
		coyote_timer -= delta
			
	if on_jump_timer > 0:
		if is_on_floor() || coyote_timer > 0:
			velocity.y = jump_velocity
			on_jump_timer = 0
			coyote_timer = 0
		else:
			on_jump_timer -= delta
	
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		
	move_and_slide()

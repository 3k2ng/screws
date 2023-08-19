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


var wall_jump_timer = 0

var prev_dir
var can_jump:bool = false

var on_jump_timer:float = 0
@export var on_jump_timer_max:float 

var coyote_timer:float = 0
@export var coyote_timer_max:float

func _ready():
	pass

func _physics_process(delta):
	# Add the gravity.
	
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
	
	
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		if wall_jump_timer <= 0:
			velocity.x = direction * movement_speed
	else:
		if wall_jump_timer <= 0:
			velocity.x = move_toward(velocity.x, 0, movement_speed)

	#print (direction)

	if not is_on_floor():
		if velocity.y < 0:
			velocity.y += jump_gravity*delta
		else:
			if is_on_wall() && direction != 0:
				velocity.y += fall_gravity*delta/10
			else:
				velocity.y += fall_gravity*delta
				
	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if not is_on_wall():
			on_jump_timer = on_jump_timer_max
		else:
			if prev_dir != 0:
				on_jump_timer = on_jump_timer_max
			else:
				on_jump_timer = on_jump_timer_max
			
	if Input.is_action_just_released("jump"):
		if velocity.y < 0:
			velocity.y = 0
		
	if is_on_floor():
		coyote_timer = coyote_timer_max

	if (is_on_wall_only() && direction != 0):
		coyote_timer = coyote_timer_max
		prev_dir = direction
		
	if coyote_timer > 0:
		coyote_timer -= delta
	else:
		prev_dir = direction

	if on_jump_timer > 0:
		if is_on_floor() || coyote_timer > 0:
			if prev_dir != 0:
				
				velocity.x = -movement_speed * 2 * prev_dir 
				print(velocity.x)
				velocity.y = jump_velocity
				on_jump_timer = 0
				wall_jump_timer = 0.1
				coyote_timer = 0
			else:
				velocity.y = jump_velocity
				on_jump_timer = 0
				coyote_timer = 0
		else:
			on_jump_timer -= delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

		
	move_and_slide()

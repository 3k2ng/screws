extends CharacterBody2D

const BLOCK_SIZE: int = 128

@export var extra_jumps: int = 0
@onready var extra_jumps_left: int = 0

@export var movement_speed_blocks: float = 4
@export var wall_bounce_blocks: float = 4
@export var jump_height_blocks : float = 4
@export var wall_slide_speed_blocks : float = 2

@export var jump_time_to_peak : float = 0.6
@export var jump_time_to_descent : float = 0.4

@onready var jump_noise = $JumpNoise

@onready var jump_height: float = jump_height_blocks * BLOCK_SIZE
@onready var wall_bounce: float = wall_bounce_blocks * BLOCK_SIZE
@onready var movement_speed: float = movement_speed_blocks * BLOCK_SIZE
@onready var wall_slide_speed: float = wall_slide_speed_blocks * BLOCK_SIZE

@onready var jump_velocity: float = -2.0 * jump_height / jump_time_to_peak
@onready var jump_gravity: float = 2.0 * jump_height / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = 2.0 * jump_height / (jump_time_to_descent * jump_time_to_descent)

@onready var max_fall_speed: float = fall_gravity * jump_time_to_descent

@export var coyote_floor_time: float = 0.16
@onready var coyote_floor_timer: float = 0.0

@export var coyote_wall_time: float = 0.16
@onready var coyote_wall_timer: float = 0.0
@onready var wall_normal_x: float = 0.0

@export var jump_buffer_time: float = 0.2
@onready var jump_buffer_timer: float = 0.0

@export var wall_bounce_time: float = 0.16
@onready var wall_bounce_timer: float = 0.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	var direction = Input.get_axis("move_left", "move_right")
	if wall_bounce_timer > 0:
		if direction * velocity.x > 0:
			wall_bounce_timer = 0
	elif direction:
		velocity.x = direction * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)
	
	if is_on_floor():
		coyote_floor_timer = coyote_floor_time
		extra_jumps_left = extra_jumps

	if is_on_wall_only() && direction:
		coyote_wall_timer = coyote_wall_time
		extra_jumps_left = extra_jumps
		wall_normal_x = get_slide_collision(0).get_normal().x
	
	if Input.is_action_just_pressed("dash") and Input.is_action_just_pressed("move_right"):
		velocity.x = BLOCK_SIZE*48
	elif Input.is_action_just_pressed("dash") and Input.is_action_just_pressed("move_left"):
		velocity.x = -BLOCK_SIZE*48
		
	if Input.is_action_just_pressed("jump"):
		jump_noise.play()
		jump_buffer_timer = jump_buffer_time
	
	# If jump is pressed (jump_buffer_timer > 0) and either of the coyote timer is active
	if jump_buffer_timer > 0 and (coyote_floor_timer > 0 or coyote_wall_timer > 0 or extra_jumps_left > 0):
		# coyote_wall_timer means wall jump
		if coyote_wall_timer > 0:
			if wall_normal_x < 0:
				velocity.x = -wall_bounce
				wall_bounce_timer = wall_bounce_time
			elif wall_normal_x > 0:
				velocity.x = wall_bounce
				wall_bounce_timer = wall_bounce_time
			coyote_wall_timer = 0
		elif coyote_floor_timer <= 0:
			extra_jumps_left -= 1
		else:
			coyote_floor_timer = 0
		velocity.y = jump_velocity
		jump_buffer_timer = 0
	
	# Update gravity
	if velocity.y >= 0:
		# Cap gravity at wall slide speed if touching wall
		if is_on_wall_only() and (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")):
			velocity.y = minf(velocity.y + fall_gravity * delta, wall_slide_speed)
		else:
			velocity.y = minf(velocity.y + fall_gravity * delta, max_fall_speed)
	else:
		# Cut upward velocity if release jump button
		if not Input.is_action_pressed("jump") or is_on_ceiling():
			velocity.y = 0
		else:
			velocity.y += jump_gravity * delta
	
	move_and_slide()
	
	# Update timers
	if coyote_floor_timer > 0:
		coyote_floor_timer -= delta
	
	if coyote_wall_timer > 0:
		coyote_wall_timer -= delta
	
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	if wall_bounce_timer > 0:
		wall_bounce_timer -= delta

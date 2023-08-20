extends CharacterBody2D

const BLOCK_SIZE: int = 128

@export var extra_jumps: int = 1
@onready var extra_jumps_left: int = 0

@export var movement_speed_blocks: float = 4
@export var wall_bounce_blocks: float = 4
@export var jump_height_blocks : float = 4
@export var wall_slide_speed_blocks : float = 2

@export var jump_time_to_peak : float = 0.6
@export var jump_time_to_descent : float = 0.4

@onready var jump_noise = $JumpNoise

@onready var nail_bullet = preload("res://sources/objects/nail_bullet.tscn")

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

@export var dash_length_blocks:float = 5
@export var dash_speed_blocks_per_second:float =  15


@onready var dash_speed:float = dash_speed_blocks_per_second * BLOCK_SIZE
@onready var dash_length = dash_length_blocks * BLOCK_SIZE

@onready var dash_timer_max: float = dash_length/dash_speed
@onready var dash_timer: float = 0.0

@export var dash_buffer_timer_max:float = 0.6
@onready var dash_buffer_timer:float = 0

@export var shoot_timer_max:float = 0.6
@onready var shoot_timer:float = 0

var is_shooting = false

enum{DASH,FREE,HIT}

var direction = 0
var state = FREE

func _ready() -> void:
	pass
	
func dash(delta):
	
	if is_on_wall() || dash_timer < 0 || ($Sprite.animation == "dash_end" &&  not $Sprite.is_playing()):
		state = FREE
		return
		
	return
	
func movement(delta):
	
	direction = Input.get_axis("move_left", "move_right")
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

	if is_on_wall_only() && (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")):
		coyote_wall_timer = coyote_wall_time
		extra_jumps_left = extra_jumps
		wall_normal_x = get_slide_collision(0).get_normal().x
	
	if Input.is_action_just_pressed("dash") && dash_buffer_timer <= 0:
		if direction == 0:
			if $Sprite.flip_h == false:
				direction = -1
			else:
				direction = 1
		velocity.x = dash_speed * direction
		velocity.y = 0
		dash_timer = dash_timer_max
		dash_buffer_timer = dash_buffer_timer_max
		state = DASH
		return
		
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

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("shoot"):
		is_shooting = true
	if Input.is_action_just_released("shoot"):
		is_shooting = false
	
	if state == DASH:
		dash(delta)
		dash_anim()
		
	if state == FREE:
		movement(delta)
		movement_anim()
		
	if state == HIT:
		velocity.y += jump_gravity * delta
		if velocity.y >= 0 && is_on_floor():
			state = FREE
			print("test")
	
	move_and_slide()
	
	if is_shooting && shoot_timer <= 0 && state != HIT:
		shoot_timer = shoot_timer_max
		var nailbul = nail_bullet.instantiate()
		nailbul.position = self.position
		nailbul.position.y += 20
		if $Sprite.flip_h == true:
			nailbul.position.x += 20
			nailbul.set_direction(1)
		else:
			nailbul.position.x -= 20
			nailbul.set_direction(-1)
		self.get_parent().add_child(nailbul)
		
		
	
	# Update timers
	if shoot_timer > 0:
		shoot_timer -= delta
	
	if coyote_floor_timer > 0:
		coyote_floor_timer -= delta
	
	if coyote_wall_timer > 0:
		coyote_wall_timer -= delta
	
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	if wall_bounce_timer > 0:
		wall_bounce_timer -= delta
		
	if dash_timer > 0:
		dash_timer -= delta
		
	if dash_buffer_timer > 0:
		dash_buffer_timer -= delta

func dash_anim():
	if dash_timer > 0:
		$Sprite.play("dash")
	#elif $Sprite.animation == "dash":
	#	$Sprite.play("dash_end")
	pass

func movement_anim():
	if velocity.x > 0:
		$Sprite.flip_h = true
	elif velocity.x < 0:
		$Sprite.flip_h = false
	
	var bleh = ""
	
	if is_shooting:
		bleh = "_gun"
	
	if is_on_floor():
		if velocity.x == 0:
			$Sprite.play("idle" + bleh)
		else:
			$Sprite.play("walk" + bleh)
	elif velocity.y > 0 && is_on_wall_only() && (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")):
		$Sprite.play("wall" + bleh)
		if wall_normal_x < 0:
			$Sprite.flip_h = false
		else:
			$Sprite.flip_h = true		
	else:
		if velocity.y >= 0:
			$Sprite.play("fall" + bleh)
		else:
			$Sprite.play("jump" + bleh)

func hit(knockback):
	$Sprite.play("hurt")
	state = HIT
	velocity.x = knockback
	
	velocity.y = abs(knockback) * -2

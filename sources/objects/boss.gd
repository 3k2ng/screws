extends CharacterBody2D

var state
enum{CHARGE, PATROL, STUNNED, SHOOT_TOAST}
const BLOCK_SIZE: int = 128

@export var movement_speed_blocks: float = 1.5
@export var moving_distance_blocks: float = 4

@onready var movement_speed: float = movement_speed_blocks*BLOCK_SIZE
@onready var moving_distance: float = moving_distance_blocks*BLOCK_SIZE

@onready var start_point: float = global_position.x
@onready var end_point: float = global_position.x + moving_distance
@onready var player_node = get_tree().get_first_node_in_group("player")

@onready var is_moving_right = true
var stun_timer = 0

var charge_dir = 0

var toast_shoot_dur = 0

var toast_shoot_delay_max = 0.2
var toast_shoot_delay = 0

var start_pos

var attack_timer = 0

@onready var toast_bullet = preload("res://sources/objects/toast_bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = position
	state = PATROL

# Called every frame. 'delta' is the elapsed time since the previous frame.

func see_player():
	if !player_node:
		state = PATROL
		return
		
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player_node.global_position + Vector2(0,64))
	query.exclude = [self, player_node]
	var result = space_state.intersect_ray(query)
	
	if result.size() > 0:
		state = PATROL
		return
		
	var relative_position_x : float = (player_node.global_position.x - global_position.x)
	
	if abs(relative_position_x) > 800:
		state = PATROL
		return
		
	if player_node.position.y < self.position.y - 32 || player_node.position.y > self.position.y + 32:
		state = PATROL	
		return
		
	$Sprite.play("angy")
	charge_dir = relative_position_x / abs(relative_position_x)
	state = CHARGE	
	print("stat")
	
	return

func _process(delta):
	if state == PATROL:
		if attack_timer > 0:
			attack_timer -= delta
			return
		var rng = RandomNumberGenerator.new()
		var ran = 0
		if player_node && player_node.is_on_floor():
			ran = rng.randi_range(1,3)
		else:
			ran = randi_range(1,2)
			
		if ran == 3:
			var relative_position_x : float = (player_node.global_position.x - global_position.x)
			charge_dir = relative_position_x / abs(relative_position_x)
			state = CHARGE
		else:
			state = SHOOT_TOAST
			toast_shoot_dur = 3
	
	
	pass

func _physics_process(delta):
	
	var relative_position_x : float = (player_node.global_position.x - global_position.x)
	if state == PATROL:

		$Sprite.play("patrol")
		if position.x >= player_node.position.x || (is_on_wall() && is_moving_right):
			is_moving_right = false
		elif position.x <= player_node.position.x || (is_on_wall() && !is_moving_right):
			is_moving_right = true
		if is_moving_right:
			$Sprite.flip_h = true
			velocity.x = movement_speed
		else:
			$Sprite.flip_h = false
			velocity.x = -movement_speed
	elif state == CHARGE:
		$Sprite.play("angy")
		#charge_noise.play()
		velocity.x =  charge_dir * movement_speed*2.5
		if is_on_wall():
			state = STUNNED
			stun_timer = 2
		pass
	elif state == STUNNED:
		$Sprite.play("crash")
		stun_timer -= delta
		if stun_timer <= 0:
			state = PATROL
			attack_timer = 2
		velocity.x = 0
	
	elif state == SHOOT_TOAST:
		velocity.x = 0
		$Sprite.play("toast_shoot")
		if toast_shoot_dur > 0:
			if toast_shoot_delay > 0:
				toast_shoot_delay -= delta
			else:
				toast_shoot_delay = toast_shoot_delay_max
				
				shoot_toast()
			toast_shoot_dur -= delta
		else:
			state = PATROL
			attack_timer = 3
		
	if not is_on_floor():
		velocity.y += 512 * delta
	move_and_slide()
	
func on_shot():
	pass

func shoot_toast():
	var ntoast = toast_bullet.instantiate()
	ntoast.position = self.position
	ntoast.bsp = start_pos
	self.get_parent().add_child(ntoast)

func _on_area_2d_body_entered(body):
	if state == CHARGE:
		if body == player_node:
			body.hit(1.5 * velocity.x)
		state = STUNNED
		stun_timer = 2
	else:
		if body == player_node:
			if player_node.position.x > self.position.x:
				body.hit(300 + velocity.x)		
			else:
				body.hit(-300 + velocity.x)		
	pass # Replace with function body.

extends CharacterBody2D

signal win

var state
enum{IDLE, CHARGE, PATROL, STUNNED, SHOOT_TOAST, HAPPY, JUMP}
const BLOCK_SIZE: int = 128

@export var movement_speed_blocks: float = 1.5
@export var moving_distance_blocks: float = 4

@onready var movement_speed: float = movement_speed_blocks*BLOCK_SIZE
@onready var moving_distance: float = moving_distance_blocks*BLOCK_SIZE

@onready var start_point: float = global_position.x
@onready var end_point: float = global_position.x + moving_distance
@onready var player_node = get_tree().get_first_node_in_group("player")

@onready var floor_toast_spawner = preload("res://sources/objects/floor_toast_spawner.tscn")
@onready var wall_toast = preload("res://sources/objects/wall_toast.tscn")
@onready var is_moving_right = true
var stun_timer = 0

var charge_dir = 0

var toast_shoot_dur_max = 3
var toast_shoot_dur = 0

var toast_shoot_delay_max = 0.2
var toast_shoot_delay = 0

var num_toast = toast_shoot_dur_max/toast_shoot_delay_max
var num_lane = 3

var toast_x

var start_pos

var range = 8 * 2 * 64

var squish_timer = 0

var attack_timer = 0

@onready var toast_bullet = preload("res://sources/objects/toast_bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = position
	state = IDLE

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

func enable():
	if state == IDLE:
		state = PATROL

func _process(delta):
	if state == IDLE:
		return
	
	if state == PATROL:
		if attack_timer > 0:
			attack_timer -= delta
			return
		var rng = RandomNumberGenerator.new()
		var ran = 0
		ran = rng.randi_range(1,3)
		
		
		if ran == 3:
			var relative_position_x : float = (player_node.global_position.x - global_position.x)
			charge_dir = relative_position_x / abs(relative_position_x)
			state = CHARGE
		elif ran == 2:
			state = SHOOT_TOAST
			toast_shoot_dur = toast_shoot_dur_max
		else:
			
			state = JUMP
			velocity.x = 0
			$Sprite.play("jump")
	
	
	pass

func floor_toast():
	
	var leftspawner = floor_toast_spawner.instantiate()
	var rightspawner = floor_toast_spawner.instantiate()
	leftspawner.position.x = self.position.x
	rightspawner.position.x = self.position.x
	
	leftspawner.position.y = start_pos.y + 45
	rightspawner.position.y = start_pos.y + 45
	
	leftspawner.leftx = start_pos.x - range
	leftspawner.rightx = start_pos.x + range
	
	rightspawner.leftx = start_pos.x - range
	rightspawner.rightx = start_pos.x + range
	
	leftspawner.gap = leftspawner.gap * -1
	
	self.get_parent().add_child(leftspawner)
	self.get_parent().add_child(rightspawner)
	
	
	
	pass

func _physics_process(delta):
	
	var relative_position_x : float = (player_node.global_position.x - global_position.x)
	if state == HAPPY:
		$Sprite.play("happy")
		velocity.x = 0
		return
	
	if state == JUMP:

		if $Sprite.animation == "jump" && $Sprite.frame == 2:
			self.velocity.y = -500
			$Sprite.play("jumping")
		elif $Sprite.animation != "jump":
			
			if not is_on_floor():
				if velocity.y > 0:
					velocity.y += 20
					$Sprite.play("jumping")
				else: 
					$Sprite.play("jumping")
			else:
				
				print($Sprite.animation)
				
				if $Sprite.animation != "falling":
					squish_timer = 1
					$Sprite.play("falling")
					floor_toast()
				
				print($Sprite.animation)
				
				if squish_timer <= 0:
					print("D")
					attack_timer = 2
					state = PATROL
				else:
					squish_timer -= delta

	
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
		velocity.x =  charge_dir * movement_speed*3.5
		if is_on_wall():
			var wall_normal_x = get_slide_collision(0).get_normal().x
			toast_circle(wall_normal_x)
			state = STUNNED
			stun_timer = 1
		pass
	elif state == STUNNED:
		$Sprite.play("crash")
		stun_timer -= delta
		if stun_timer <= 0:
			state = PATROL
			attack_timer = 1
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
				shoot_toast()
				shoot_toast()				
				shoot_toast()
			toast_shoot_dur -= delta
		else:
			num_toast = toast_shoot_dur_max/toast_shoot_delay_max
			state = PATROL
			attack_timer = 1.5
	
	
	if not is_on_floor():
		velocity.y += 512 * 1.5 * delta
	move_and_slide()

func toast_circle(normal):
	var num_circle = 3
	for i in range(0, num_circle):
		var angle_from = 180 * normal
		
		var angle_to = 90 * normal
		
		var cur_angle = angle_from
		
		var num_toasts = 5
		
		for j in range(0, num_toasts):
			
			var ntoast = wall_toast.instantiate()
			ntoast.position = self.position
			
			var direction = Vector2(-normal * cos(deg_to_rad(cur_angle)), sin(deg_to_rad(cur_angle)))
			ntoast.dir = direction
			ntoast.speed = 300 - (75 * i)
			cur_angle += normal * (angle_to / num_toasts)
			
			self.get_parent().add_child(ntoast)
	
	
	
func on_shot():
	if player_node.position.x > self.position.x:
		$Screw2.position.x -= 2
	else:
		$Screw.position.x += 2
			
	if $Screw2.position.x <= 40 && $Screw.position.x >= -40:
		state = HAPPY
		win.emit()
	pass

func shoot_toast():
	var ntoast = toast_bullet.instantiate()
	ntoast.position = self.position
	ntoast.bsp = start_pos
	ntoast.toastx = toast_x
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

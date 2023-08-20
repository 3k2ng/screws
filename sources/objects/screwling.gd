extends CharacterBody2D

var state
enum{APPROACHING, PATROL, HAPPY}
const BLOCK_SIZE: int = 128
const screwling_health = 3
var screwling_health_counter = 0

@export var sight_dist_blocks:int = 3
@onready var sight_dist = sight_dist_blocks * BLOCK_SIZE

@onready var hurt_noise = $HurtNoise

@export var movement_speed_blocks: float = 1
@export var moving_distance_blocks: float = 4

@onready var movement_speed: float = movement_speed_blocks*BLOCK_SIZE
@onready var moving_distance: float = moving_distance_blocks*BLOCK_SIZE

@onready var start_point: float = global_position.x
@onready var end_point: float = global_position.x + moving_distance
@onready var player_node = get_tree().get_first_node_in_group("player")
@onready var nail_node = get_tree().get_first_node_in_group("nail")
@onready var is_moving_right = true

@export var button_pair:Node2D

var transition_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	state =PATROL

# Called every frame. 'delta' is the elapsed time since the previous frame.

func see_player():
	if !player_node:
		state = PATROL
		return
		
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player_node.global_position)
	query.exclude = [self, player_node]
	var result = space_state.intersect_ray(query)
	
	if result.size() > 0:
		state = PATROL
		return
		
	var relative_position_x : float = (player_node.global_position.x - global_position.x)
	
	if abs(relative_position_x) > sight_dist:
		state = PATROL
		return
	
	if transition_timer >= 0:
		return
	
	transition_timer = 5
	state = APPROACHING
	
	return

func _process(delta):
	see_player()
	
	if transition_timer >= 0:
		transition_timer -= delta
	pass

func _physics_process(delta):
	var relative_position_x : float = (player_node.global_position.x - global_position.x)
	if screwling_health == screwling_health_counter:
		state = HAPPY
	if state == PATROL:
		$AnimatedSprite2D.play("patrol")
		if position.x >= end_point || (is_on_wall() && is_moving_right):
			is_moving_right = false
		elif position.x <= start_point || (is_on_wall() && !is_moving_right):
			is_moving_right = true
		if is_moving_right:
			$AnimatedSprite2D.flip_h = true
			velocity.x = movement_speed
		else:
			$AnimatedSprite2D.flip_h = false
			velocity.x = -movement_speed
	elif state == APPROACHING:
		$AnimatedSprite2D.play("angy")
		if(relative_position_x < 0):
			$AnimatedSprite2D.flip_h = false
			velocity.x = -movement_speed
		elif(relative_position_x > 0):
			$AnimatedSprite2D.flip_h = true
			velocity.x = movement_speed
	elif state == HAPPY:
		pass
	if not is_on_floor():
		velocity.y += 512 * delta
	move_and_slide()

func on_shot():
	hurt_noise.play()
	screwling_health_counter = screwling_health_counter+1
	
func _on_area_2d_body_entered(body):
	if state == APPROACHING:
		if body == player_node:
			body.hit(3.5 * velocity.x)
	pass # Replace with function body.

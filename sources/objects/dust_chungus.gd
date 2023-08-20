extends CharacterBody2D

var state
enum{CHARGE, PATROL, STUNNED}
const BLOCK_SIZE: int = 128

@export var movement_speed_blocks: float = 1
@export var moving_distance_blocks: float = 4

@onready var movement_speed: float = movement_speed_blocks*BLOCK_SIZE
@onready var moving_distance: float = moving_distance_blocks*BLOCK_SIZE

@onready var start_point: float = global_position.x
@onready var end_point: float = global_position.x + moving_distance
@onready var player_node = get_tree().get_first_node_in_group("player")

@onready var is_moving_right = true
var stun_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	state = PATROL

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
	
	if abs(relative_position_x) > 300:
		state = PATROL
		return
		
	state = CHARGE	
	
	return

func _process(delta):
	pass

func _physics_process(delta):
	
	var relative_position_x : float = (player_node.global_position.x - global_position.x)
	if state == PATROL:
		see_player()
		if position.x >= end_point || is_on_wall():
			is_moving_right = false
		elif position.x <= start_point || is_on_wall():
			is_moving_right = true
		if is_moving_right:
			velocity.x = movement_speed
		else:
			velocity.x = -movement_speed
	elif state == CHARGE:
		if(relative_position_x >= -300 and relative_position_x < 0):
			velocity.x = -movement_speed*2.5
		elif(relative_position_x >= 0 and relative_position_x < 300):
			velocity.x = movement_speed*2.5
		pass
	elif state == STUNNED:
		stun_timer -= delta
		if stun_timer <= 0:
			state = PATROL
		velocity.x = 0
		
	if not is_on_floor():
		velocity.y += 512 * delta
	move_and_slide()
	
func _on_area_2d_body_entered(body):
	if state == CHARGE:
		state = STUNNED
		stun_timer = 5
	pass # Replace with function body.

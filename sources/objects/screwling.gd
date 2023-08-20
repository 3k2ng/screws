extends CharacterBody2D

var state
enum{APPROACHING, PATROL}
const BLOCK_SIZE: int = 128

@export var movement_speed_blocks: float = 1
@export var moving_distance_blocks: float = 4

@onready var movement_speed: float = movement_speed_blocks*BLOCK_SIZE
@onready var moving_distance: float = moving_distance_blocks*BLOCK_SIZE

@onready var start_point: float = global_position.x
@onready var end_point: float = global_position.x + moving_distance
@onready var player_node = get_tree().get_first_node_in_group("player")
@onready var player_point: float = player_node.position.x
@onready var distance_from_player: float = (position.x - player_point)

@onready var vision = $Vision
@onready var is_moving_right = true

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = movement_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	#state = PATROL	
	if player_node:
		$Vision.look_at(player_node.position)

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
	

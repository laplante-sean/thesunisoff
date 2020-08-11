extends KinematicBody2D
class_name NPC

export(int) var ACCELERATION = 100
export(int) var MAX_SPEED = 30
export(int) var FRICTION = 200
export(int) var WANDER_TARGET_RANGE = 4

enum NPCState {
	IDLE,
	WANDER,
	PLAYER_DETECTED
}

var velocity = Vector2.ZERO
var state = NPCState.IDLE

onready var sprite = $AnimatedSprite
onready var playerDetectionZone = $PlayerDetectionZone
onready var wanderController = $WanderController


func _ready():
	state = pick_random_state([NPCState.IDLE, NPCState.WANDER])


func _physics_process(delta):
	match state:
		NPCState.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			check_and_update_state()
		NPCState.WANDER:
			seek_player()
			check_and_update_state()
			move_toward_position(wanderController.target_position, delta)
			sprite.flip_h = velocity.x < 0

			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				state = pick_random_state([NPCState.IDLE, NPCState.WANDER])
				wanderController.start_wander_timer(rand_range(1, 3))
		NPCState.PLAYER_DETECTED:
			player_detected(delta)
			sprite.flip_h = velocity.x < 0

	velocity = move_and_slide(velocity)


func player_detected(_delta):
	# This method should be overidden to customize NPC behavior when near
	# the player
	var player = playerDetectionZone.player
	if player == null:
		state = NPCState.IDLE

func seek_player():
	if playerDetectionZone.can_see_player():
		state = NPCState.PLAYER_DETECTED


func move_toward_position(pos, delta):
	var direction = global_position.direction_to(pos)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)


func check_and_update_state():
	if wanderController.get_time_left() == 0:
		state = pick_random_state([NPCState.IDLE, NPCState.WANDER])
		wanderController.start_wander_timer(rand_range(1, 3))


func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

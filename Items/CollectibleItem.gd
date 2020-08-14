extends KinematicBody2D
class_name CollectibleItem

enum ItemState {
	WANDER,
	STATIONARY,
	CHASE
}

export(int) var MAX_SPEED = 5
export(int) var ACCELERATION = 5
export(int) var WANDER_RANGE = 10
export(int) var WANDER_TARGET_RANGE = 4
export(int) var ITEM_ID = 0  # This must be set in sub-classes to the
							 # correct item ID if IS_MONEY is false
export(bool) var IS_MONEY = false
export(ItemState) var STARTING_STATE = ItemState.WANDER

var velocity = Vector2.ZERO
var state = ItemState.WANDER
var target = Vector2.ZERO

onready var playerDetectionZone = $PlayerDetectionZone
onready var collider = $Collider
onready var sprite = $Sprite


func _ready():
	state = STARTING_STATE
	var target_vector = Vector2(
		rand_range(-WANDER_RANGE, WANDER_RANGE),
		rand_range(-WANDER_RANGE, WANDER_RANGE)
	)
	target = position + target_vector
	collider.disabled = true


func _physics_process(delta):
	match state:
		ItemState.WANDER:
			move_toward_position(target, delta)
			if global_position.distance_to(target) <= WANDER_TARGET_RANGE:
				state = ItemState.STATIONARY
		ItemState.STATIONARY:
			collider.disabled = false
			velocity = Vector2.ZERO
			seek_player()
		ItemState.CHASE:
			var player = playerDetectionZone.player
			if player != null:
				move_toward_position(player.global_position, delta)
			else:
				state = ItemState.STATIONARY


func seek_player():
	if playerDetectionZone.can_see_player():
		state = ItemState.CHASE


func move_toward_position(pos, delta):
	var direction = global_position.direction_to(pos)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	move_and_collide(velocity)


func collect():
	"""
	Sub-classes CAN override this (but don't have to) if they need to
	store additional information with the item in the player's inventory
	"""
	return {
		item_id = ITEM_ID
	}

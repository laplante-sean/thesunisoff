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

var velocity = Vector2.ZERO
var state = ItemState.WANDER
var target = Vector2.ZERO

onready var playerDetectionZone = $PlayerDetectionZone
onready var collider = $Collider
onready var sprite = $Sprite


func _ready():
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
	position += velocity


func collect():
	"""
	Sub-classes must implement collect to update the
	PlayerStats with the result of collecting the item
	"""
	print("Collecting ", self)


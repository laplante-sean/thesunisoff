extends KinematicBody2D
class_name Enemy

const ExplodeEffect = preload("res://Effects/ExplodeEffect.tscn")

export(int) var ACCELERATION = 100
export(int) var MAX_SPEED = 30
export(int) var FRICTION = 200
export(int) var WANDER_TARGET_RANGE = 4
export(int) var SOFT_COLLISION_PUSH_FACTOR = 200
export(float) var INVICIBILITY_TIME = 0.4

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var state = CHASE

onready var hurtbox = $Hurtbox
onready var sprite = $AnimatedSprite
onready var stats = $EnemyStats
onready var playerDetectionZone = $PlayerDetectionZone
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer


func _ready():
	state = pick_random_state([IDLE, WANDER])


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			check_and_update_state()
		WANDER:
			seek_player()
			check_and_update_state()
			move_toward_position(wanderController.target_position, delta)
			sprite.flip_h = velocity.x < 0

			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				state = pick_random_state([IDLE, WANDER])
				wanderController.start_wander_timer(rand_range(1, 3))
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				move_toward_position(player.global_position, delta)
			else:
				state = IDLE
			sprite.flip_h = velocity.x < 0

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * SOFT_COLLISION_PUSH_FACTOR

	velocity = move_and_slide(velocity)


func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE


func move_toward_position(pos, delta):
	var direction = global_position.direction_to(pos)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)


func check_and_update_state():
	if wanderController.get_time_left() == 0:
		state = pick_random_state([IDLE, WANDER])
		wanderController.start_wander_timer(rand_range(1, 3))


func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()


func _on_Hurtbox_area_entered(area):
	if hurtbox.invincible:
		return

	stats.health -= area.damage
	
	if area is KnockbackHitbox:
		if area.knockback_vector == Vector2.ZERO:
			var knockback_vector = area.global_position.direction_to(global_position)
			knockback = knockback_vector * area.KNOCKBACK_FACTOR
		else:
			knockback = area.knockback_vector * area.KNOCKBACK_FACTOR

	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(INVICIBILITY_TIME)


func _on_Hurtbox_invincibility_started():
	animationPlayer.play("StartFlash")


func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("StopFlash")


func _on_EnemyStats_no_health():
	queue_free()
	Utils.instance_scene_on_main(ExplodeEffect, sprite.global_position)

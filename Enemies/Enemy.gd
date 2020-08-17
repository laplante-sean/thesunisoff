extends KinematicBody2D
class_name Enemy

const ExplodeEffect = preload("res://Effects/ExplodeEffect.tscn")

export(int) var ACCELERATION = 100
export(int) var MAX_SPEED = 30
export(int) var FRICTION = 200
export(int) var WANDER_TARGET_RANGE = 4
export(int) var WANDER_MIN_TIME = 1
export(int) var WANDER_MAX_TIME = 3
export(int) var SOFT_COLLISION_PUSH_FACTOR = 200
export(float) var INVICIBILITY_TIME = 0.4

enum EnemyState {
	IDLE,
	WANDER,
	CHASE,
	ATTACK
}

var pre_buf_max_speed = MAX_SPEED
var movement_buffed = false
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var state = EnemyState.CHASE
var health_bar_scale_x = 1

onready var hurtbox = $Hurtbox
onready var sprite = $AnimatedSprite
onready var healthBar = $HealthBarSprite
onready var stats = $EnemyStats
onready var playerDetectionZone = $PlayerDetectionZone
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var blinkAnimationPlayer = $BlinkAnimationPlayer


func _ready():
	set_physics_process(false)
	health_bar_scale_x = healthBar.scale.x
	var mat = sprite.get_material()
	mat.set_shader_param("active", false)
	state = pick_random_state([EnemyState.IDLE, EnemyState.WANDER])


func _physics_process(delta):
	if stats.max_health == 1:
		healthBar.visible = false
	else:
		healthBar.visible = true

	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

	match state:
		EnemyState.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			check_and_update_state()
		EnemyState.WANDER:
			seek_player()
			check_and_update_state()
			move_toward_position(wanderController.target_position, delta)

			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				state = pick_random_state([EnemyState.IDLE, EnemyState.WANDER])
				wanderController.start_wander_timer(rand_range(WANDER_MIN_TIME, WANDER_MAX_TIME))
		EnemyState.CHASE:
			var player = playerDetectionZone.player
			if player != null:
				chase(player, delta)
			else:
				state = EnemyState.IDLE
		EnemyState.ATTACK:
			var player = playerDetectionZone.player
			if player != null:
				attack(player, delta)
				chase(player, delta)
			else:
				state = EnemyState.IDLE

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * SOFT_COLLISION_PUSH_FACTOR

	velocity = move_and_slide(velocity)
	sprite.flip_h = velocity.x < 0


func attack(player, delta):
	# Override to implement
	pass


func chase(player, delta):
	# Override to change
	move_toward_position(player.global_position, delta)
	if global_position.distance_to(player.global_position) <= WANDER_TARGET_RANGE:
		state = EnemyState.ATTACK
	else:
		state = EnemyState.CHASE


func seek_player():
	if playerDetectionZone.can_see_player():
		state = EnemyState.CHASE


func move_toward_position(pos, delta):
	if global_position.distance_to(pos) <= WANDER_TARGET_RANGE and state == EnemyState.CHASE:
		state = EnemyState.ATTACK
	elif state == EnemyState.ATTACK:
		state = EnemyState.CHASE
	
	var direction = global_position.direction_to(pos)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)


func check_and_update_state():
	if wanderController.get_time_left() == 0:
		state = pick_random_state([EnemyState.IDLE, EnemyState.WANDER])
		wanderController.start_wander_timer(rand_range(WANDER_MIN_TIME, WANDER_MAX_TIME))


func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()


func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("StartFlash")


func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("StopFlash")


func _on_EnemyStats_no_health():
	queue_free()
	Utils.instance_scene_on_main(ExplodeEffect, sprite.global_position)


func _on_Hurtbox_take_damage(area):
	stats.health -= area.DAMAGE
	
	var rem_health_factor = float(stats.health) / float(stats.max_health)
	healthBar.scale.x = rem_health_factor * health_bar_scale_x
	
	if area.ENABLE_KNOCKBACK:
		if area.knockback_vector == Vector2.ZERO:
			var knockback_vector = area.global_position.direction_to(global_position)
			knockback = knockback_vector * area.KNOCKBACK_FACTOR
		else:
			knockback = area.knockback_vector * area.KNOCKBACK_FACTOR

	if area.MOVEMENT_BUF < 1 and not movement_buffed:
		# This area slows an enemy down
		pre_buf_max_speed = MAX_SPEED
		MAX_SPEED *= area.MOVEMENT_BUF
		movement_buffed = true

	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(INVICIBILITY_TIME)


func _on_Hurtbox_end_movement_buf(area):
	# Restore full movement
	MAX_SPEED = pre_buf_max_speed
	movement_buffed = false


func _on_VisibilityEnabler2D_screen_entered():
	set_physics_process(true)


func _on_VisibilityEnabler2D_screen_exited():
	set_physics_process(false)

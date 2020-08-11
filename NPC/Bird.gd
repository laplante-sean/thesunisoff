extends NPC

export(int) var FLIGHT_SPEED = 75
export(int) var FLIGHT_ACCELERATION = 250

var fly_direction = Vector2.ZERO


func _physics_process(delta):
	match state:
		NPCState.IDLE:
			sprite.animation = "Idle"
		NPCState.WANDER:
			sprite.animation = "Walk"


func player_detected(delta):
	# This will be called by the parent class' _physics_process
	# when the player is detected
	sprite.animation = "Fly"

	# Once we pick a direction, just fly forever until off screen
	if fly_direction == Vector2.ZERO:
		fly_direction = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()

	velocity = velocity.move_toward(fly_direction * FLIGHT_SPEED, FLIGHT_ACCELERATION * delta)



func _on_VisibilityNotifier2D_screen_exited():
	# De-spawn when off-screen
	queue_free()

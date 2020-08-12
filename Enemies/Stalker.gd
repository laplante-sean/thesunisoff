extends Enemy

const EnemyBullet = preload("res://Enemies/EnemyBullet.tscn")

export(int) var MIN_DISTANCE_TO_PLAYER = 12

onready var attackTimer = $AttackTimer


func _physics_process(delta):
	match state:
		EnemyState.IDLE:
			sprite.speed_scale = 1.0
		EnemyState.WANDER:
			sprite.speed_scale = 1.0
		EnemyState.CHASE:
			sprite.speed_scale = 2


func attack(player, delta):
	if attackTimer.time_left > 0:
		return
	
	var direction = global_position.direction_to(player.global_position)
	var bullet = Utils.instance_scene_on_main(EnemyBullet, global_position)

	bullet.velocity = direction
	attackTimer.start()


func chase(player, delta):
	# Override to make stalker hover at a distance from the player
	var pos = player.global_position
	pos += (global_position.direction_to(pos) * -1) * MIN_DISTANCE_TO_PLAYER
	move_toward_position(pos, delta)


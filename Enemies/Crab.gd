extends "res://Enemies/Enemy.gd"


func _physics_process(delta):
	match state:
		EnemyState.IDLE:
			sprite.animation = "Idle"
		EnemyState.WANDER:
			sprite.animation = "Scurry"
		EnemyState.CHASE:
			sprite.animation = "Scurry"

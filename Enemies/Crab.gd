extends "res://Enemies/Enemy.gd"


func _physics_process(delta):
	match state:
		IDLE:
			sprite.animation = "Idle"
		WANDER:
			sprite.animation = "Scurry"
		CHASE:
			sprite.animation = "Scurry"

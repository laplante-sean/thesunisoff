extends NPC


func _physics_process(delta):
	match state:
		NPCState.IDLE:
			sprite.speed_scale = 1
		NPCState.WANDER:
			sprite.speed_scale = 2

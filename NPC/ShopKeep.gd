extends NPC


func _physics_process(delta):
	match state:
		NPCState.IDLE:
			sprite.animation = "Idle"
		NPCState.WANDER:
			sprite.animation = "Walk"


func interact():
	Utils.say_dialog("What're you buyin'?")

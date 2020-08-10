extends Stats

export(int) var experience_value = 10


func _on_EnemyStats_no_health():
	PlayerStats.collect_experience(experience_value)
	PlayerStats.enemies_killed += 1

extends Stats

export(int) var experience_value = 10


func _ready():
	self.max_health += PlayerStats.enemy_health_boost
	self.health += PlayerStats.enemy_health_boost
	PlayerStats.connect("boost_enemy_health", self, "_on_PlayerStats_boost_enemy_health")


func _on_PlayerStats_boost_enemy_health(value):
	self.max_health += 1
	self.health += 1


func _on_EnemyStats_no_health():
	PlayerStats.collect_experience(experience_value)
	PlayerStats.enemies_killed += 1

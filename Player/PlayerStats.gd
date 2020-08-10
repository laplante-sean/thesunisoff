extends Stats

var enemies_killed = 0
var deaths = 0


func save_data():
	return {
		max_health = self.max_health,
		health = self.health,
		enemies_killed = self.enemies_killed,
		deaths = self.deaths
	}


func load_data(stats):
	self.max_health = stats.max_health
	self.deaths = stats.deaths
	self.enemies_killed = stats.enemies_killed
	if stats.health != 0:
		self.health = stats.health


func _on_PlayerStats_no_health():
	self.deaths += 1
	SaveAndLoad.save_game()

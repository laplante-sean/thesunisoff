extends Stats

var enemies_killed = 0
var deaths = 0
var total_experience = 0
var level = 1 setget set_level
var experience = 0 setget set_experience
var money = 0 setget set_money
var inventory = {}

var next_level_exp_threshold = 100

signal money_changed(value)
signal collected_item(item_data)
signal experience_changed(value)
signal level_changed(value)


func save_data():
	return {
		max_health = self.max_health,
		health = self.health,
		enemies_killed = self.enemies_killed,
		deaths = self.deaths,
		level = self.level,
		experience = self.experience,
		total_experience = self.total_experience,
		money = self.money,
		inventory = self.inventory
	}


func load_data(stats):
	self.level = stats.level
	self.max_health = max(stats.max_health, self.max_health)
	self.deaths = stats.deaths
	self.enemies_killed = stats.enemies_killed
	self.experience = stats.experience
	self.total_experience = stats.total_experience
	self.money = stats.money
	self.inventory = stats.inventory
	if stats.health != 0:
		self.health = stats.health


func set_money(value):
	money = max(value, 0)
	emit_signal("money_changed", money)


func set_level(value):
	level = max(value, 0)
	next_level_exp_threshold = 100 + ((level - 1) * 10)
	emit_signal("level_changed", level)


func set_experience(value):
	experience = value
	
	if experience >= next_level_exp_threshold:
		self.level += 1
		experience = 0

	emit_signal("experience_changed", experience)


func collect_item(item_data):
	var item_id = str(item_data.item_id)

	if not item_id in self.inventory:
		self.inventory[item_id] = []

	self.inventory[str(item_id)].append(item_data)
	emit_signal("collected_item", item_data)


func collect_experience(amount):
	self.experience += amount
	self.total_experience += amount


func _on_PlayerStats_no_health():
	self.deaths += 1
	SaveAndLoad.save_game()


func _on_PlayerStats_level_changed(value):
	SaveAndLoad.save_game()

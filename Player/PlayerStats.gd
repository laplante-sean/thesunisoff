extends Stats

export(int) var max_magic = 100 setget set_max_magic
export(float) var magic_regen_timeout = 5

var enemies_killed = 0
var deaths = 0
var total_experience = 0
var level = 1 setget set_level
var experience = 0 setget set_experience
var money = 0 setget set_money
var magic = 0 setget set_magic
var inventory = {}
var first_time = true

var next_level_exp_threshold = 100

signal money_changed(value)
signal collected_item(item_data)
signal experience_changed(value)
signal level_changed(value)
signal max_magic_changed(value)
signal magic_changed(value)
signal level_up

onready var magicRegenTimer = $MagicRegenTimer
onready var magicRegenRate = $MagicRegenRate


func _ready():
	self.magic = self.max_magic
	magicRegenTimer.wait_time = magic_regen_timeout


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
		inventory = self.inventory,
		max_magic = self.max_magic
	}


func load_data(stats):
	self.level = stats.level
	self.max_health = max(stats.max_health, self.max_health)
	self.deaths = stats.deaths
	self.enemies_killed = stats.enemies_killed
	self.experience = stats.experience
	self.total_experience = stats.total_experience
	self.money = stats.money
	self.max_magic = stats.max_magic
	self.inventory = stats.inventory
	self.first_time = false
	if stats.health != 0:
		self.health = stats.health


func set_magic(value):
	if value < magic and not magicRegenRate.is_stopped():
		magicRegenRate.stop()
	
	magic = clamp(value, 0, self.max_magic)
	
	if magic < self.max_magic and magicRegenTimer.is_stopped():
		magicRegenTimer.start()
	elif magic == self.max_magic:
		magicRegenRate.stop()
		magicRegenTimer.stop()
	
	emit_signal("magic_changed", magic)


func set_max_magic(value):
	max_magic = value
	self.magic = min(self.magic, max_magic)
	emit_signal("max_magic_changed", max_magic)


func set_money(value):
	money = max(value, 0)
	emit_signal("money_changed", money)


func set_level(value):
	value = max(value, 0)
	level = clamp(value, 0, 99)
	next_level_exp_threshold = 100 + ((level - 1) * 10)
	emit_signal("level_changed", level)


func set_experience(value):
	var leveled_up = false
	experience = value
	
	while experience >= next_level_exp_threshold:
		experience -= next_level_exp_threshold
		self.level += 1
		
		if int(self.level) % 5 == 0:
			self.max_health = min(self.max_health + 1, 10)
			self.health = self.max_health
			self.max_magic = min(self.max_magic + 10, 500)
		
		if not leveled_up:
			emit_signal("level_up")
			leveled_up = true
			SaveAndLoad.save_game()

	emit_signal("experience_changed", experience)


func collect_item(item_data):
	var item_id = str(item_data.item_id)

	if not item_id in self.inventory:
		self.inventory[item_id] = []

	self.inventory[str(item_id)].append(item_data)
	emit_signal("collected_item", item_data)


func use_item(item_id):
	if not has_item(item_id):
		return null

	var matched_items = self.inventory[str(item_id)]
	return matched_items.pop_front()


func has_item(item_id):
	if count_item(item_id) == 0:
		return false
	return true


func count_item(item_id):
	if not str(item_id) in self.inventory:
		return 0
	var matched_items = self.inventory[str(item_id)]
	return len(matched_items)


func collect_experience(amount):
	self.experience += amount
	self.total_experience += amount


func _on_PlayerStats_no_health():
	self.deaths += 1
	self.health = max_health
	SaveAndLoad.save_game()


func describe_inventory():
	var message = "Coin: {coins}\n".format({"coins": self.money})
	var door_keys = count_item(ItemUtils.get_item_id("DoorKey"))
	var chest_keys = count_item(ItemUtils.get_item_id("ChestKey"))
	var fire_potions = count_item(ItemUtils.get_item_id("FirePotion"))
	var ice_potions = count_item(ItemUtils.get_item_id("IcePotion"))
	var health_potions = count_item(ItemUtils.get_item_id("HealthPotion"))

	if door_keys > 0:
		message += "Door Key: {door_keys}\n".format({"door_keys": door_keys})
	if chest_keys > 0:
		message += "Chest Key: {chest_keys}\n".format({"chest_keys": chest_keys})
	if fire_potions > 0:
		message += "Fire Potions: {fire_potions}\n".format({"fire_potions": fire_potions})
	if ice_potions > 0:
		message += "Ice Potions: {ice_potions}\n".format({"ice_potions": ice_potions})
	if health_potions > 0:
		message += "Health Potions: {health_potions}\n".format({"health_potions": health_potions})

	Utils.say_dialog(message)


func _on_MagicRegenTimer_timeout():
	magicRegenRate.start()


func _on_MagicRegenRate_timeout():
	self.magic += 5

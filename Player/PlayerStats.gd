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
var enemy_health_boost = 0
var weapon_hitpoint_boost = 0
var sword_knockback = 75 setget set_sword_knockback
var spell_knockback = 100 setget set_spell_knockback
var spell_360_knockback = 150 setget set_spell_360_knockback
var current_level_path = "res://Levels/Overworld.tscn"
var overworld_return_point = Vector2.ZERO
var inventory = {}
var first_time = true

var next_level_exp_threshold = 100

signal money_changed(value)
signal collected_item(item_data)
signal experience_changed(value)
signal level_changed(value)
signal max_magic_changed(value)
signal magic_changed(value)
signal sword_knockback_changed(value)
signal spell_knockback_changed(value)
signal spell_360_knockback_changed(value)
signal boost_enemy_health(value)
signal boost_attack_strength(value)
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
		max_magic = self.max_magic,
		sword_knockback = self.sword_knockback,
		spell_360_knockback = self.spell_360_knockback,
		spell_knockback = self.spell_knockback,
		current_level_path = self.current_level_path,
		overworld_return_point = {
			x = self.overworld_return_point.x,
			y = self.overworld_return_point.y
		},
		enemy_health_boost = self.enemy_health_boost,
		weapon_hitpoint_boost = self.weapon_hitpoint_boost
	}


func load_data(stats):
	self.level = stats.get("level", 1)
	self.max_health = stats.get("max_health", self.max_health)
	self.deaths = stats.get("deaths", 0)
	self.enemies_killed = stats.get("enemies_killed", 0)
	self.experience = stats.get("experience", 0)
	self.total_experience = stats.get("total_experience", 0)
	self.money = stats.get("money", 0)
	self.max_magic = stats.get("max_magic", self.max_magic)
	self.sword_knockback = stats.get("sword_knockback", self.sword_knockback)
	self.spell_knockback = stats.get("spell_knockback", self.spell_knockback)
	self.spell_360_knockback = stats.get("spell_360_knockback", self.spell_360_knockback)
	self.inventory = stats.get("inventory", {})
	self.current_level_path = stats.get("current_level_path", self.current_level_path)
	self.overworld_return_point.x = stats.get("overworld_return_point", {}).get("x", 0)
	self.overworld_return_point.y = stats.get("overworld_return_point", {}).get("y", 0)
	self.enemy_health_boost = stats.get("enemy_health_boost", 0)
	self.weapon_hitpoint_boost = stats.get("weapon_hitpoint_boost", 0)
	self.first_time = false
	if stats.get("health", self.health) != 0:
		self.health = stats.get("health", self.health)


func set_sword_knockback(value):
	sword_knockback = clamp(value, 75, 125)
	emit_signal("sword_knockback_changed", value)


func set_spell_knockback(value):
	spell_knockback = clamp(value, 100, 150)
	emit_signal("spell_knockback_changed", value)


func set_spell_360_knockback(value):
	spell_360_knockback = clamp(value, 150, 200)
	emit_signal("spell_360_knockback_changed", value)


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


func increase_stats():
	self.max_health = min(self.max_health + 1, 10)
	self.health = self.max_health
	self.max_magic = min(self.max_magic + 10, 500)
	self.sword_knockback += 5
	self.spell_knockback += 5
	self.spell_360_knockback += 5
	self.enemy_health_boost = min(self.enemy_health_boost + 1, 5)
	emit_signal("boost_enemy_health", self.enemy_health_boost)


func set_experience(value):
	var leveled_up = false
	experience = value
	
	while experience >= next_level_exp_threshold:
		experience -= next_level_exp_threshold
		self.level += 1
		
		if int(self.level) % 5 == 0:
			self.increase_stats()
			
		if int(self.level) % 10 == 0:
			self.weapon_hitpoint_boost += 1
			emit_signal("boost_attack_strength", self.weapon_hitpoint_boost)

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


func has_all_four_amulets():
	var fire = false
	var earth = false
	var water = false
	var air = false
	
	if has_item(ItemUtils.get_item_id("FireAmulet")):
		fire = true
	if has_item(ItemUtils.get_item_id("EarthAmulet")):
		earth = true
	if has_item(ItemUtils.get_item_id("WaterAmulet")):
		water = true
	if has_item(ItemUtils.get_item_id("AirAmulet")):
		air = true

	if fire and earth and water and air:
		return true

	return false


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
	var fire = false
	var earth = false
	var water = false
	var air = false
	
	var message = "Coin: {coins}".format({"coins": self.money})
	var door_keys = count_item(ItemUtils.get_item_id("DoorKey"))
	var chest_keys = count_item(ItemUtils.get_item_id("ChestKey"))
	var fire_potions = count_item(ItemUtils.get_item_id("FirePotion"))
	var ice_potions = count_item(ItemUtils.get_item_id("IcePotion"))
	var health_potions = count_item(ItemUtils.get_item_id("HealthPotion"))

	if door_keys > 0:
		message += "\nDoor Key: {door_keys}".format({"door_keys": door_keys})
	if chest_keys > 0:
		message += "\nChest Key: {chest_keys}".format({"chest_keys": chest_keys})
	if fire_potions > 0:
		message += "\nFire Potions: {fire_potions}".format({"fire_potions": fire_potions})
	if ice_potions > 0:
		message += "\nIce Potions: {ice_potions}".format({"ice_potions": ice_potions})
	if health_potions > 0:
		message += "\nHealth Potions: {health_potions}".format({"health_potions": health_potions})

	if has_item(ItemUtils.get_item_id("FireAmulet")):
		fire = true
	if has_item(ItemUtils.get_item_id("EarthAmulet")):
		earth = true
	if has_item(ItemUtils.get_item_id("WaterAmulet")):
		water = true
	if has_item(ItemUtils.get_item_id("AirAmulet")):
		air = true

	if fire or earth or water or air:
		message += "\nAmulets:"
		if fire:
			message += "\n Fire"
		if earth:
			message += "\n  Earth"
		if water:
			message += "\n  Water"
		if air:
			message += "\n  Air"

	Utils.say_dialog(message)


func describe_stats():
	var message = "Health: {max_health}".format({"max_health": self.max_health})
	message += "\nMagic: {max_magic}".format({"max_magic": self.max_magic})
	message += "\nSword Dmg: {sword_damage}".format({"sword_damage": 1 + self.weapon_hitpoint_boost})
	message += "\nSword Pwr: {sword_knockback}".format({"sword_knockback": self.sword_knockback})
	message += "\nSpell Dmg: {spell_damage}".format({"spell_damage": 2 + self.weapon_hitpoint_boost})
	message += "\nSpell Pwr: {spell_knockback}".format({"spell_knockback": self.spell_knockback})
	message += "\n360 Dmg: {spell_360_damage}".format({"spell_360_damage": 3 + self.weapon_hitpoint_boost})
	message += "\n360 Pwr: {spell_360_knockback}".format({"spell_360_knockback": self.spell_360_knockback})
	message += "\nEnemy HP: +{enemy_health_boost}".format({"enemy_health_boost": self.enemy_health_boost})
	
	Utils.say_dialog(message)


func _on_MagicRegenTimer_timeout():
	magicRegenRate.start()


func _on_MagicRegenRate_timeout():
	self.magic += 5

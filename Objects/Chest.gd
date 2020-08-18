extends InteractibleObject
class_name Chest

const ChestOpenSound = preload("res://Audio/ChestOpenSound.tscn")
const ChestCloseSound = preload("res://Audio/ChestCloseSound.tscn")
const LockedDoorSound = preload("res://Audio/LockedDoorSound.tscn")

enum ChestState {
	LOCKED,
	UNLOCKED,
	OPEN
}

# This will be an array of strings where each string is a tuple
# of item_id,quantity
export(Array, String) var CONTENTS = []
export(ChestState) var STARTING_STATE = ChestState.LOCKED
export(String) var LOCKED_MESSAGE = "Sorry, the chest is locked."
export(bool) var RANDOM_CHEST = false
export(bool) var IGNORE_SAVE = false
export(bool) var UNLOCK_WITH_KEY = true

var state = ChestState.LOCKED setget set_state

onready var animationPlayer = $AnimationPlayer


func _ready():
	self.state = STARTING_STATE
	
	if RANDOM_CHEST:
		CONTENTS = []
		var num_potions = int(rand_range(1, 3))
		var num_coins = int(rand_range(20, 100))
		
		CONTENTS.append("{id},{quantity}".format({
			"id": ItemUtils.get_item_id("Coin"),
			"quantity": num_coins
		}))
		
		for idx in range(num_potions):
			var potion_chance = int(rand_range(0, 100))
			var potion_item = null

			if potion_chance > 50 and potion_chance < 80:
				potion_item = "FirePotion"
			elif potion_chance > 80:
				potion_item = "IcePotion"
			else:
				potion_item = "HealthPotion"
			
			CONTENTS.append("{id},1".format(
				{"id": ItemUtils.get_item_id(potion_item)}
			))


func is_locked():
	return self.state == ChestState.LOCKED


func unlock():
	self.state = ChestState.UNLOCKED


func set_state(value):
	state = value
	
	match state:
		ChestState.LOCKED:
			sprite.frame = 0
		ChestState.UNLOCKED:
			sprite.frame = 1
		ChestState.OPEN:
			sprite.frame = 5


func interact():
	match self.state:
		ChestState.LOCKED:
			Utils.instance_scene_on_main(LockedDoorSound, global_position)
			Utils.say_dialog(LOCKED_MESSAGE)
		ChestState.UNLOCKED:
			Utils.instance_scene_on_main(ChestOpenSound, global_position)
			animationPlayer.play("Open")
		ChestState.OPEN:
			Utils.instance_scene_on_main(ChestCloseSound, global_position)
			animationPlayer.play_backwards("Open")


func _on_AnimationPlayer_animation_finished(anim_name):
	if self.state == ChestState.OPEN:
		self.state = ChestState.UNLOCKED
		return

	self.state = ChestState.OPEN
	
	for item in CONTENTS:
		item = item.strip_edges()
		var item_info = item.split(",", false, 2)
		var item_id = int(item_info[0].strip_edges())
		var item_quantity = int(item_info[1].strip_edges())
	
		for i in range(item_quantity):
			ItemUtils.instance_item_on_main(item_id, global_position)

	CONTENTS = []


func save_data():
	return {
		pos = {
			x = global_position.x,
			y = global_position.y
		},
		contents = CONTENTS
	}


func load_data(data):
	CONTENTS = []
	for item in data.contents:
		CONTENTS.append(item)

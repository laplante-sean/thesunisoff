extends "res://Objects/InteractibleObject.gd"
class_name Chest

enum ChestState {
	LOCKED,
	UNLOCKED,
	OPEN
}

# This will be an array of strings where each string is a tuple
# of item_id,quantity
export(Array, String) var CONTENTS = []
export(ChestState) var STARTING_STATE = ChestState.LOCKED

var state = ChestState.LOCKED setget set_state

onready var animationPlayer = $AnimationPlayer


func _ready():
	self.state = STARTING_STATE


func is_locked():
	return state == ChestState.LOCKED


func unlock():
	state = ChestState.UNLOCKED


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
	match state:
		ChestState.LOCKED:
			print("Sorry, the chest is locked. You need a key")
		ChestState.UNLOCKED:
			animationPlayer.play("Open")
		ChestState.OPEN:
			print("Already open")


func _on_AnimationPlayer_animation_finished(anim_name):
	self.state = ChestState.OPEN
	
	for item in CONTENTS:
		item = item.strip_edges()
		var item_info = item.split(",", false, 2)
		var item_id = int(item_info[0].strip_edges())
		var item_quantity = int(item_info[1].strip_edges())
	
		for i in range(item_quantity):
			ItemUtils.instance_item_on_main(item_id, global_position)

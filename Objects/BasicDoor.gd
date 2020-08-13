extends InteractibleObject
class_name Door

const DoorOpenSound = preload("res://Audio/DoorOpenSound.tscn")
const DoorCloseSound = preload("res://Audio/DoorCloseSound.tscn")

enum DoorState {
	LOCKED,
	UNLOCKED,
	OPEN
}

export(DoorState) var STARTING_STATE = DoorState.LOCKED

var state = DoorState.LOCKED setget set_state


func _ready():
	self.state = STARTING_STATE


func is_locked():
	return self.state == DoorState.LOCKED


func unlock():
	self.state = DoorState.UNLOCKED


func set_state(value):
	state = value
	
	match state:
		DoorState.LOCKED:
			collider.disabled = false
			occluder.light_mask = 1
			sprite.frame = 0
		DoorState.UNLOCKED:
			collider.disabled = false
			occluder.light_mask = 1
			sprite.frame = 1
		DoorState.OPEN:
			collider.disabled = true
			occluder.light_mask = 0
			sprite.frame = 2


func interact():
	match self.state:
		DoorState.LOCKED:
			Utils.say_dialog("The door is locked")
		DoorState.UNLOCKED:
			Utils.instance_scene_on_main(DoorOpenSound, global_position)
			self.state = DoorState.OPEN
		DoorState.OPEN:
			Utils.instance_scene_on_main(DoorCloseSound, global_position)
			self.state = DoorState.UNLOCKED

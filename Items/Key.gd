extends CollectibleItem
class_name Key

const PickupSound = preload("res://Audio/PickupSound.tscn")

enum KeyType {
	CHEST,
	DOOR
}

export(KeyType) var KEY_TYPE = KeyType.CHEST


func collect():
	match KEY_TYPE:
		KeyType.CHEST:
			Utils.say_dialog("You've collected 1 chest key. Use it to unlock a locked chest.")
		KeyType.DOOR:
			Utils.say_dialog("You've collected 1 door key. Use it to unlock a locked door.")
	
	Utils.instance_scene_on_main(PickupSound, global_position)
	var data = .collect()
	data["key_type"] = KEY_TYPE
	return data

extends CollectibleItem
class_name Key

const PickupSound = preload("res://Audio/PickupSound.tscn")

enum KeyType {
	CHEST,
	DOOR
}

export(KeyType) var KEY_TYPE = KeyType.CHEST


func collect():
	Utils.instance_scene_on_main(PickupSound, global_position)
	var data = .collect()
	data["key_type"] = KEY_TYPE
	return data

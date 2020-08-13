extends CollectibleItem
class_name Key

const PickupSound = preload("res://Audio/PickupSound.tscn")

enum KeyType {
	CHEST,
	DOOR
}

export(KeyType) var KEY_TYPE = KeyType.CHEST


func _ready():
	match KEY_TYPE:
		KeyType.CHEST:
			sprite.frame = 0
		KeyType.DOOR:
			sprite.frame = 1


func collect():
	Utils.instance_scene_on_main(PickupSound, global_position)
	var data = .collect()
	data["key_type"] = KEY_TYPE
	return data

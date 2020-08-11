extends CollectibleItem
class_name Key

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
	var data = .collect()
	data["key_type"] = KEY_TYPE
	return data

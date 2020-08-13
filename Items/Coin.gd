extends CollectibleItem
class_name Coin

const CollectCoinsSound = preload("res://Audio/CollectCoinsSound.tscn")

export(int) var VALUE = 1


func collect():
	Utils.instance_scene_on_main(CollectCoinsSound, global_position)
	var data = .collect()
	data["value"] = VALUE
	return data

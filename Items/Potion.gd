extends CollectibleItem
class_name Potion

const PickupPotionSound = preload("res://Audio/PickupPotionSound.tscn")

enum PotionType {
	FIRE,
	ICE,
	HEALTH
}

export(PotionType) var POTION_TYPE = PotionType.FIRE


func collect():
	Utils.instance_scene_on_main(PickupPotionSound, global_position)
	var data = .collect()
	data["potion_type"] = POTION_TYPE
	return data


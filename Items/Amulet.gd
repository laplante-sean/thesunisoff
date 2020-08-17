extends CollectibleItem
class_name Amulet

const PickupAmuletSound = preload("res://Audio/PickupAmuletSound.tscn")

enum AmuletType {
	FIRE,
	WATER,
	AIR,
	EARTH
}

export(AmuletType) var AMULET_TYPE = AmuletType.FIRE
export(int) var EXPERIENCE_AMOUNT = 200


func collect():
	PlayerStats.collect_experience(EXPERIENCE_AMOUNT)
	Utils.instance_scene_on_main(PickupAmuletSound, global_position)
	var data = .collect()
	data["amulet_type"] = AMULET_TYPE
	Events.emit_signal("amulet_collected", AMULET_TYPE)
	return data

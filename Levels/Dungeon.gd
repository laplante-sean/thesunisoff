extends Level
class_name Dungeon

var spawner_count = 0
var defeated = 0

signal all_defeated
signal one_defeated


func _ready():
	Events.connect("amulet_collected", self, "_on_Events_amulet_collected")

	for child in ySortTileMap.get_children():
		if child is NPCSpawner:
			child.connect("defeated", self, "_on_Spawner_defeated")
			spawner_count += 1


func _on_Spawner_defeated():
	defeated += 1
	emit_signal("one_defeated")

	if defeated >= spawner_count:
		emit_signal("all_defeated")


func _on_Events_amulet_collected(type):
	var type_str = ""

	match type:
		Amulet.AmuletType.AIR:
			type_str = "Air"
		Amulet.AmuletType.EARTH:
			type_str = "Earth"
		Amulet.AmuletType.WATER:
			type_str = "Water"
		Amulet.AmuletType.FIRE:
			type_str = "Fire"
	
	Utils.call_deferred("say_dialog", "You have collected the {type} amulet!".format({"type": type_str}))

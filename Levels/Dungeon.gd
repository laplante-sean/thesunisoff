extends Level
class_name Dungeon

var spawner_count = 0
var defeated = 0

signal all_defeated
signal one_defeated


func _ready():
	for child in ySortTileMap.get_children():
		if child is NPCSpawner:
			child.connect("defeated", self, "_on_Spawner_defeated")
			spawner_count += 1


func _on_Spawner_defeated():
	defeated += 1
	emit_signal("one_defeated")

	if defeated >= spawner_count:
		emit_signal("all_defeated")

extends Dungeon

onready var door = $YSortTileMap/BasicDoor


func _on_WaterDungeon_all_defeated():
	Utils.call_deferred("say_dialog", "The door to the final chamber has been unlocked.")
	door.unlock()

extends Dungeon

onready var door = $YSortTileMap/WideDoor


func _on_FireDungeon_all_defeated():
	Utils.call_deferred("say_dialog", "The door to the final chamber has been unlocked.")
	door.unlock()

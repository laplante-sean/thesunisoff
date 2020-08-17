extends Dungeon

onready var iceChest = $YSortTileMap/IceChest
onready var firstDoor = $YSortTileMap/FirstDoor
onready var finalDoor = $YSortTileMap/FinalDoor


func _on_IceGhostSpawner_defeated():
	Utils.call_deferred("say_dialog", "A nearby chest has been unlocked.")
	iceChest.unlock()


func _on_AirDungeon_one_defeated():
	if defeated >= 3 and firstDoor.is_locked():
		Utils.call_deferred("say_dialog", "The door to the next chamber has been unlocked.")
		firstDoor.unlock()
	if defeated >= 7 and finalDoor.is_locked():
		Utils.call_deferred("say_dialog", "The door to the final chamber has been unlocked.")
		finalDoor.unlock()

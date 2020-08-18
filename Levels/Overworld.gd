extends Level

onready var castleEarthDoor = $YSortTileMap/CastleEarthDoor
onready var castleAirDoor = $YSortTileMap/CastleAirDoor


func _ready():
	Events.connect("level_loaded", self, "_on_Events_level_loaded")


func _on_Events_level_loaded(level_id):
	if level_id != "overworld":
		return

	if PlayerStats.count_amulets() >= 2 and castleEarthDoor.is_locked():
		castleEarthDoor.unlock()
		Utils.say_dialog("The door to the earth amulet has been unlocked. Go with honor!")
	if PlayerStats.count_amulets() >= 3 and castleAirDoor.is_locked():
		castleAirDoor.unlock()
		Utils.say_dialog("The door to the air amulet has been unlocked. Go with fury!")

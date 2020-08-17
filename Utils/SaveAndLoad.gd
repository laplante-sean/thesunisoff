extends Node

const SAVE_DATA_PATH = "res://save_data.json"

signal let_there_be_light

var MainInstances = Utils.get_main_instances()

var save_data = null


func mark_overworld_enemies_undefeated():
	if save_data == null:
		return  # This should be impossible

	if not save_data.has("overworld"):
		return  # This should also be impossible

	# Bring the enemies back
	for spawner in save_data["overworld"].get("enemy_spawners", []):
		spawner.defeated = false

	# Also refill the chests
	save_data["overworld"].chests = []

	save_game()


func save_game():
	if save_data == null:
		save_data = {
			"darkness": true
		}

	save_data["player_stats"] = PlayerStats.save_data()

	var current_level = Utils.get_current_level()
	if current_level != null:
		save_data[current_level.LEVEL_ID] = current_level.save_data()
	
	_save_data_to_file(save_data)


func load_game():
	save_data = _load_data_from_file()
	if save_data == null:
		Events.emit_signal("no_save_data")
		return  # No save file. Nothing to load

	if not save_data.get("darkness", true):
		emit_signal("let_there_be_light")

	PlayerStats.load_data(save_data.player_stats)

	load_level(PlayerStats.current_level_path)


func load_level(path):
	var current_level = Utils.get_current_level()
	if current_level != null:
		save_game()
		current_level.queue_free()

	current_level = Utils.instance_scene_on_main(load(path))
	PlayerStats.current_level_path = path
	MainInstances.current_level = current_level
	
	if save_data != null and save_data.has(current_level.LEVEL_ID):
		current_level.load_data(save_data[current_level.LEVEL_ID])

	save_game()


func _save_data_to_file(data):
	"""
	Write a file with the current save data
	
	:param save_data: Data to save to the file
	"""
	var json_string = to_json(data)
	var save_file = File.new()
	save_file.open(SAVE_DATA_PATH, File.WRITE)
	save_file.store_line(json_string)
	save_file.close()


func _load_data_from_file():
	"""
	Load save data from our save location
	
	:returns: The loaded save data or the default save data if a new game.
	"""
	var save_file = File.new()
	if not save_file.file_exists(SAVE_DATA_PATH):
		return null
		
	save_file.open(SAVE_DATA_PATH, File.READ)
	var data = parse_json(save_file.get_as_text())
	save_file.close()
	return data

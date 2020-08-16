extends Node

const SAVE_DATA_PATH = "res://save_data.json"


func save_game():
	var save_data = {
		player_stats = PlayerStats.save_data()
	}
	
	var current_level = Utils.get_current_level()
	if current_level != null:
		save_data[current_level.LEVEL_ID] = current_level.save_data()
	
	_save_data_to_file(save_data)


func load_game():
	var save_data = _load_data_from_file()
	if save_data == null:
		Events.emit_signal("no_save_data")
		return  # No save file. Nothing to load

	PlayerStats.load_data(save_data.player_stats)

	var current_level = Utils.get_current_level()
	if current_level != null and save_data.has(current_level.LEVEL_ID):
		current_level.load_data(save_data[current_level.LEVEL_ID])


func _save_data_to_file(save_data):
	"""
	Write a file with the current save data
	
	:param save_data: Data to save to the file
	"""
	var json_string = to_json(save_data)
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
	var save_data = parse_json(save_file.get_as_text())
	save_file.close()
	return save_data

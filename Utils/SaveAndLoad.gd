extends Node

const SAVE_DATA_PATH = "user://the_sun_is_off_save_data.json"

export(String, FILE, "*.tscn") var tutorial_level_path = "res://Levels/Tutorial.tscn"

signal let_there_be_light

var MainInstances = Utils.get_main_instances()
var play_tutorial_question = "Would you like to play the tutorial?"

var save_data = null


func _ready():
	Events.connect("yesno_answer", self, "_on_Events_yesno_answer")


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
		save_game()  # Create initial save
		save_data = _load_data_from_file()

	if not save_data.get("darkness", true):
		emit_signal("let_there_be_light")

	PlayerStats.load_data(save_data.player_stats)
	
	if not PlayerStats.tutorial_complete:
		PlayerStats.tutorial_complete = true
		Utils.ask_dialog(play_tutorial_question, true)
	else:
		load_level(PlayerStats.current_level_path)


func _on_Events_yesno_answer(question, answer):
	if question == play_tutorial_question and answer:
		call_deferred("load_level", tutorial_level_path)
	elif question == play_tutorial_question and not answer:
		call_deferred("load_level", PlayerStats.current_level_path)


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

	Events.emit_signal("level_loaded", current_level.LEVEL_ID)
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

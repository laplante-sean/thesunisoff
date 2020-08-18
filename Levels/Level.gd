extends Node2D
class_name Level

const Player = preload("res://Player/Player.tscn")

export(String) var LEVEL_ID = ""

var retry_question = "You are dead. Continue?"

onready var spawnPoint = $SpawnPoint
onready var ySortTileMap = $YSortTileMap
onready var deathWaitTime = $DeathWaitTime

func _ready():
	Events.connect("yesno_answer", self, "_on_Events_yesno_answer")
	PlayerStats.connect("no_health", self, "_on_PlayerStats_no_health")
	spawn()


func spawn():
	var player = Player.instance()
	ySortTileMap.add_child(player)

	if PlayerStats.overworld_return_point != Vector2.ZERO and LEVEL_ID == "overworld":
		player.global_position = PlayerStats.overworld_return_point
		PlayerStats.overworld_return_point = Vector2.ZERO
	else:
		player.global_position = spawnPoint.global_position

	player.cameraFollow.set_remote_node("../../../../Camera")
	player.lightFollow.set_remote_node("../../../../PlayerTorch")
	return player


func _on_PlayerStats_no_health():
	deathWaitTime.start()


func _on_Events_yesno_answer(question, answer):
	if question == retry_question:
		if answer:
			call_deferred("spawn")
		else:
			get_tree().quit(0)


func save_data():
	var data = {
		level_id = LEVEL_ID,
		enemy_spawners = [],
		chests = [],
		doors = []
	}
	
	for child in ySortTileMap.get_children():
		if child is NPCSpawner:
			data.enemy_spawners.append(child.save_data())
		if child is Chest and not child.IGNORE_SAVE:
			data.chests.append(child.save_data())
		if child is Door:
			data.doors.append(child.save_data())
	
	return data


func load_data(data):
	for child in ySortTileMap.get_children():
		if child is NPCSpawner:
			for spawner in data.get("enemy_spawners", []):
				var pos = Vector2(spawner.pos.x, spawner.pos.y)
				if child.global_position == pos:
					child.load_data(spawner)
					break
		elif child is Chest:
			for chest in data.get("chests", []):
				var pos = Vector2(chest.pos.x, chest.pos.y)
				if child.global_position == pos:
					child.load_data(chest)
					break
		elif child is Door:
			for door in data.get("doors", []):
				var pos = Vector2(door.pos.x, door.pos.y)
				if child.global_position == pos:
					child.load_data(door)
					break


func _on_DeathWaitTime_timeout():
	Utils.call_deferred("ask_dialog", retry_question, true)

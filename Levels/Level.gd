extends Node2D

const Player = preload("res://Player/Player.tscn")

export(String) var LEVEL_ID = ""

onready var spawnPoint = $SpawnPoint
onready var ySortTileMap = $YSortTileMap


func _ready():
	Events.connect("no_save_data", self, "_on_Events_no_save_data")
	PlayerStats.connect("no_health", self, "_on_PlayerStats_no_health")
	spawn()


func spawn():
	var player = Player.instance()
	ySortTileMap.add_child(player)
	player.global_position = spawnPoint.global_position
	player.cameraFollow.set_remote_node("../../../../Camera")
	player.lightFollow.set_remote_node("../../../../PlayerTorch")
	return player


func _on_PlayerStats_no_health():
	call_deferred("spawn")


func _on_Events_no_save_data():
	call_deferred("trigger_spawners")


func trigger_spawners():
	for child in ySortTileMap.get_children():
		if child is NPCSpawner:
			child.spawn()


func save_data():
	var data = {
		level_id = LEVEL_ID,
		enemy_spawners = [],
		chests = []
	}
	
	for child in ySortTileMap.get_children():
		if child is NPCSpawner:
			data.enemy_spawners.append(child.save_data())
		if child is Chest and not child.IGNORE_SAVE:
			data.chests.append(child.save_data())
	
	return data


func load_data(data):
	for child in ySortTileMap.get_children():
		if child is NPCSpawner:
			for spawner in data.enemy_spawners:
				var pos = Vector2(spawner.pos.x, spawner.pos.y)
				if child.global_position == pos:
					child.load_data(spawner)
					break
		elif child is Chest:
			for chest in data.chests:
				var pos = Vector2(chest.pos.x, chest.pos.y)
				if child.global_position == pos:
					child.load_data(chest)
					break


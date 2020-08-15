extends Node2D

const Player = preload("res://Player/Player.tscn")

export(String) var LEVEL_ID = ""

onready var spawnPoint = $SpawnPoint
onready var ySortTileMap = $YSortTileMap


func _ready():
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


func save_data():
	return {
		level_id = LEVEL_ID
	}


func load_data(data):
	pass  # Override to load

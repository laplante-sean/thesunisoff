extends Area2D

export(String, FILE, "*.tscn") var next_level_path = ""
export(int) var portal_id = 0
export(bool) var STAIRS_UP = false

onready var stairsUp = $StairsUp
onready var stairsDown = $StairsDown
onready var returnPosition = $ReturnPosition


func _ready():
	if STAIRS_UP:
		stairsUp.visible = true
		stairsDown.visible = false
	else:
		stairsUp.visible = false
		stairsDown.visible = true


func get_return_point():
	return returnPosition.global_position


func _on_LevelPortal_body_entered(body):
	var current_level = Utils.get_current_level()
	if current_level and current_level.LEVEL_ID == "overworld":
		PlayerStats.overworld_return_point = get_return_point()

	Events.emit_signal("next_level", next_level_path)

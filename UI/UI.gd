extends CanvasLayer

export(bool) var SHOW_PLAYER_LEVEL = true

onready var currentLevelUI = $CurrentLevelUI


func _ready():
	if not SHOW_PLAYER_LEVEL:
		currentLevelUI.visible = false

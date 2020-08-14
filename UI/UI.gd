extends CanvasLayer

export(bool) var SHOW_PLAYER_LEVEL = true

onready var currentLevelUI = $CurrentLevelUI
onready var healthUI = $HealthUI


func _ready():
	healthUI.visible = true
	if not SHOW_PLAYER_LEVEL:
		currentLevelUI.visible = false
	else:
		currentLevelUI.visible = true

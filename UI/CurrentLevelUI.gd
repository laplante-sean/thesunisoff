extends Label


func _ready():
	text = str(PlayerStats.level)
	PlayerStats.connect("level_changed", self, "_on_PlayerStats_level_changed")


func _on_PlayerStats_level_changed(level):
	text = str(level)

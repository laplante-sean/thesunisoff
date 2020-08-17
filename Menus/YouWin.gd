extends CanvasLayer

var pause = false setget set_pause

onready var label = $Label
onready var timer = $Timer


func set_pause(value):
	pause = value
	label.visible = value
	get_tree().paused = value
	
	if pause:
		timer.start()


func _on_Timer_timeout():
	self.pause = false

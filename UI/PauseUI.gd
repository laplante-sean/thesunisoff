extends Control

var pause = false setget set_pause


func _ready():
	self.pause = false


func set_pause(value):
	pause = value
	visible = value
	get_tree().paused = value


func _process(delta):
	if Input.is_action_just_pressed("pause"):
		self.pause = !self.pause


func _on_SaveButton_pressed():
	SaveAndLoad.save_game()
	self.pause = false
	Utils.say_dialog("Save complete!")


func _on_QuitButton_pressed():
	get_tree().quit(0)

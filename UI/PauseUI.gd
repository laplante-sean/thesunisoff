extends Control

var pause = false setget set_pause
var respawn_question = "Would you like to respawn? You won't loose any progress. This is here in case you get stuck because of a bug or something."


func _ready():
	self.pause = false
	Events.connect("yesno_answer", self, "_on_Events_yesno_answer")


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
	Utils.call_deferred("say_dialog", "Save complete!")


func _on_QuitButton_pressed():
	get_tree().quit(0)


func _on_Respawn_pressed():
	Utils.call_deferred("ask_dialog", respawn_question, true)
	self.pause = false


func _on_Events_yesno_answer(question, answer):
	if question == respawn_question and answer:
		SaveAndLoad.save_game()
		SaveAndLoad.call_deferred("load_level", PlayerStats.current_level_path)

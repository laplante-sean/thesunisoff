extends Label

signal message_complete

var current_message = null
var display_message = ""
var current_character = 0

onready var characterTimer = $CharacterTimer


func _process(delta):
	if len(display_message) == 0:
		visible = false
	else:
		visible = true

	text = display_message


func say(message):
	current_character = 0
	display_message = ""
	current_message = message
	characterTimer.start()


func close():
	display_message = ""
	current_character = 0
	current_message = null


func _on_CharacterTimer_timeout():
	if current_character >= len(current_message):
		emit_signal("message_complete")
		characterTimer.stop()
		current_message = null
		current_character = 0
		return
	
	display_message += current_message[current_character]
	current_character += 1

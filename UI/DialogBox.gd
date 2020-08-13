extends Control

signal dialog_complete

var current_message = null
var display_message = ""
var max_lines = 0
var max_lines_visible = 0

onready var characterTimer = $CharacterTimer
onready var label = $Label
onready var sprite = $AnimatedSprite


func _process(delta):
	if len(display_message) == 0:
		visible = false
		get_tree().paused = false
	else:
		visible = true
		get_tree().paused = true

	if label.get_line_count() > max_lines:
		max_lines = label.get_line_count()
	if label.get_visible_line_count() > max_lines_visible:
		max_lines_visible = label.get_visible_line_count()

	if max_lines_visible < max_lines:
		sprite.visible = true
	else:
		sprite.visible = false

	if Input.is_action_just_pressed("ui_accept") and current_message != null:
		if len(display_message) < len(current_message) and characterTimer.time_left > 0:
			display_message = current_message
		elif len(display_message) < len(current_message):
			characterTimer.start()
			label.lines_skipped += label.max_lines_visible
			max_lines_visible += label.max_lines_visible
		elif max_lines_visible < max_lines:
			label.lines_skipped += label.max_lines_visible
			max_lines_visible += label.max_lines_visible
		else:
			close()

	label.text = display_message


func say(message):
	current_message = message
	characterTimer.start()


func close():
	max_lines = 0
	max_lines_visible = 0
	label.lines_skipped = 0
	label.text = ""
	display_message = ""
	current_message = null
	emit_signal("dialog_complete")


func _on_CharacterTimer_timeout():
	var idx = clamp(len(display_message), 0, len(current_message))
	if idx == len(current_message):
		characterTimer.stop()
		return
	if max_lines_visible < max_lines:
		characterTimer.stop()
		return

	display_message += current_message[idx]

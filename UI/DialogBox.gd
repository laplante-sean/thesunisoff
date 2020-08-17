extends Control
class_name DialogBox

enum ShopItem {
	HEALTH,
	FIRE,
	ICE,
	NONE
}

var current_message = null
var display_message = ""
var max_lines = 0
var max_lines_visible = 0
var is_question = false
var shop_item = ShopItem.NONE
var is_shop = false
var answer = false
var pause = false setget set_pause

onready var characterTimer = $CharacterTimer
onready var label = $TextureRect/Label
onready var sprite = $AnimatedSprite
onready var yesnobox = $YesNoBox
onready var shopbox = $ShopSelection
onready var clickSound = $ClickSound


func _ready():
	self.pause = false
	label.text = ""
	yesnobox.frame = 1
	shopbox.frame = 3
	label.autowrap = true
	label.max_lines_visible = 3


func set_pause(value):
	pause = value
	visible = value
	get_tree().paused = value


func _process(delta):
	if label.get_line_count() > max_lines:
		max_lines = label.get_line_count()
	if label.get_visible_line_count() > max_lines_visible:
		max_lines_visible = label.get_visible_line_count()

	if max_lines_visible < max_lines:
		sprite.visible = true
	else:
		sprite.visible = false

	if current_message != null and len(display_message) == len(current_message) and max_lines_visible >= max_lines:
		if is_question:
			yesnobox.visible = true
			if Input.is_action_just_pressed("ui_up"):
				yesnobox.frame = 0
				answer = true
			if Input.is_action_just_pressed("ui_down"):
				yesnobox.frame = 1
				answer = false
		if is_shop:
			shopbox.visible = true
			if Input.is_action_just_pressed("ui_up"):
				shopbox.frame = max(shopbox.frame - 1, 0)
				shop_item = shopbox.frame
			if Input.is_action_just_pressed("ui_down"):
				shopbox.frame = min(shopbox.frame + 1, 3)
				shop_item = shopbox.frame
	else:
		yesnobox.visible = false
		shopbox.visible = false

	if Input.is_action_just_pressed("ui_accept") and current_message != null:
		clickSound.play()
		
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
	self.pause = true
	current_message = message
	characterTimer.start()


func ask(question, default=false):
	self.pause = true
	answer = default
	if answer:
		yesnobox.frame = 0
	else:
		yesnobox.frame = 1
	is_question = true
	current_message = question
	characterTimer.start()


func shop(message):
	self.pause = true
	is_shop = true
	current_message = message
	characterTimer.start()


func close():
	if is_question:
		Events.emit_signal("yesno_answer", current_message, answer)
	elif is_shop:
		Events.emit_signal("purchase_item", shop_item)
	else:
		Events.emit_signal("dialog_complete", current_message)
	
	max_lines = 0
	max_lines_visible = 0
	label.lines_skipped = 0
	label.text = ""
	display_message = ""
	current_message = null
	is_question = false
	is_shop = false
	answer = false
	shop_item = ShopItem.NONE
	yesnobox.frame = 1
	shopbox.frame = 3
	self.pause = false


func _on_CharacterTimer_timeout():
	if current_message == null:
		characterTimer.stop()
		return

	var idx = clamp(len(display_message), 0, len(current_message))
	if idx == len(current_message):
		characterTimer.stop()
		return
	if max_lines_visible < max_lines:
		characterTimer.stop()
		return

	display_message += current_message[idx]

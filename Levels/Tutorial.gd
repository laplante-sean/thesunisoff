extends Level

const TutorialSuccessSound = preload("res://Audio/TutorialSuccessSound.tscn")

signal task_success()

onready var takingTooLongTimer = $TakingTooLongTimer
onready var welcomeTimer = $WelcomeTimer

var taking_long_question = "Do you need me to repeat the current task for you?"
var movement = 0 setget set_movement
var current_task = 0

var prompts = [
	"Welcome. Press space to advance dialogs. Now try moving around with W,A,S,D.",
	"Excellent! Now talk to that woman over there by walking up to her, facing her, and pressing E"
]


func _ready():
	Events.connect("yesno_answer", self, "_on_Events_yesno_answer")
	welcomeTimer.start()


func set_movement(value):
	movement = value
	if movement >= 4 and current_task == 1:
		emit_signal("task_success")


func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		self.movement += 1
	if Input.is_action_just_pressed("ui_left"):
		self.movement += 1
	if Input.is_action_just_pressed("ui_right"):
		self.movement += 1
	if Input.is_action_just_pressed("ui_down"):
		self.movement += 1


func say_current_task(advance=false):
	Utils.say_dialog(prompts[current_task])
	if advance:
		current_task += 1


func _on_Events_yesno_answer(question, answer):
	if question == taking_long_question and answer:
		call_deferred("say_current_task")
	takingTooLongTimer.start()


func _on_WelcomeTimer_timeout():
	emit_signal("task_success")
	takingTooLongTimer.start()


func _on_TakingTooLongTimer_timeout():
	Utils.call_deferred("ask_dialog", taking_long_question, true)


func _on_Tutorial_task_success():
	call_deferred("say_current_task", true)
	Utils.instance_scene_on_main(TutorialSuccessSound, global_position)

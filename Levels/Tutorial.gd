extends Level

const TutorialSuccessSound = preload("res://Audio/TutorialSuccessSound.tscn")

signal task_success()

onready var takingTooLongTimer = $TakingTooLongTimer
onready var welcomeTimer = $WelcomeTimer
onready var firstDoor = $YSortTileMap/FirstDoor
onready var secondDoor = $YSortTileMap/SecondDoor
onready var thirdDoor = $YSortTileMap/ThirdDoor
onready var firstEnemyStats = $YSortTileMap/FirstEnemy/EnemyStats
onready var secondEnemyStats = $YSortTileMap/SecondEnemy/EnemyStats
onready var thirdEnemyStats = $YSortTileMap/ThirdEnemy/EnemyStats
onready var potionsTimer = $PotionsTimer
onready var fourthDoor = $YSortTileMap/FourthDoor
onready var secondArea = $SecondAreaDetection
onready var thirdArea = $ThirdAreaDetection
onready var fourthArea = $FourthAreaDetection

var taking_long_question = "Do you need me to repeat the current task for you?"
var welcome_message = "Welcome. Press space to advance dialogs. Let's go over the UI. In the top left you have health, experience, and magic. In the top right you have your level."
var first_kill_message = "Great! Killing an enemy will give you experience. Experience is shown in the green bar under your health."
var second_kill = "Awesome! Magic attacks will draw from the blue magic bar. It will replenish on its own after a short time. You can also perform a magic punch attack with Q or J."
var movement = 0 setget set_movement
var magic_kills = 0
var current_task = -1

var prompts = [
	"Now try moving around with W,A,S,D.",
	"Excellent! Now talk to that woman over there by walking up to her, facing her, and pressing E",
	"The door to the next area has been unlocked. Proceed through the door by pressing E to open it",
	"Up ahead is an enemy. Attack it with your sword by pressing the space bar.",
	"The door to the next area has been unlocked. Proceed through the door by pressing E to open it",
	"Up ahead are two enemies. Stand inbetween them and press F or K to perform a 360 degree attack.",
	"The door to the next area has been unlocked. Proceed through the door. You probably know how to open doors by now.",
	"Walk up to the chest and open it by pressing E",
	"This chest contained a health, fire, and ice potion. The currently equiped potion is displayed in the top right. To equip, use 1 for health, 2 for fire, and 3 for ice. To use the currently equiped potion, press G or L",
	"When you're ready, proceed throught the next door and up the stairs to begin the game."
]


func _ready():
	Events.connect("dialog_complete", self, "_on_Events_dialog_complete")
	Events.connect("yesno_answer", self, "_on_Events_yesno_answer")
	firstEnemyStats.connect("no_health", self, "_on_first_kill")
	secondEnemyStats.connect("no_health", self, "_on_magic_kill")
	thirdEnemyStats.connect("no_health", self, "_on_magic_kill")
	welcomeTimer.start()


func set_movement(value):
	movement = value
	if movement >= 4 and current_task == 0:
		emit_signal("task_success")


func _process(delta):
	if Input.is_action_just_pressed("ui_up") and current_task == 0:
		self.movement += 1
	if Input.is_action_just_pressed("ui_left") and current_task == 0:
		self.movement += 1
	if Input.is_action_just_pressed("ui_right") and current_task == 0:
		self.movement += 1
	if Input.is_action_just_pressed("ui_down") and current_task == 0:
		self.movement += 1


func say_current_task():
	if current_task >= len(prompts):
		return
	
	Utils.say_dialog(prompts[current_task])


func _on_Events_yesno_answer(question, answer):
	if question == taking_long_question and answer:
		call_deferred("say_current_task")
	elif question == taking_long_question and not answer:
		takingTooLongTimer.start()


func _on_Events_dialog_complete(message):
	if message == welcome_message:
		current_task = 0
		call_deferred("say_current_task")
	elif message == first_kill_message:
		secondDoor.unlock()
		emit_signal("task_success")
	elif message == second_kill:
		thirdDoor.unlock()
		emit_signal("task_success")


func _on_magic_kill():
	magic_kills += 1
	if magic_kills >= 2:
		Utils.call_deferred("say_dialog", second_kill)


func _on_WelcomeTimer_timeout():
	Utils.call_deferred("say_dialog", welcome_message)
	takingTooLongTimer.start()


func _on_TakingTooLongTimer_timeout():
	Utils.call_deferred("ask_dialog", taking_long_question, true)


func _on_Tutorial_task_success():
	current_task += 1
	call_deferred("say_current_task")
	takingTooLongTimer.start()
	Utils.instance_scene_on_main(TutorialSuccessSound, global_position)


func _on_Tutorial_tutorial_complete():
	pass # Replace with function body.


func _on_InteractWithWomanNPC_interacted_with():
	if current_task == 1:
		emit_signal("task_success")
		firstDoor.unlock()


func _on_SecondAreaDetection_body_entered(body):
	emit_signal("task_success")
	secondArea.queue_free()


func _on_first_kill():
	Utils.call_deferred("say_dialog", first_kill_message)


func _on_ThirdAreaDetection_body_entered(body):
	emit_signal("task_success")
	thirdArea.queue_free()


func _on_FourthAreaDetection_body_entered(body):
	emit_signal("task_success")
	fourthArea.queue_free()


func _on_PotionChest_interacted_with(object):
	emit_signal("task_success")
	fourthDoor.unlock()
	potionsTimer.start()


func _on_PotionsTimer_timeout():
	emit_signal("task_success")
	takingTooLongTimer.stop()

extends Node2D

onready var theDarkness = $TheDarkness
onready var uiDialogBox = $UI/DialogBox


func _ready():
	# We turn visibility off when
	# making levels. This ensures it's always
	# back on for testing
	uiDialogBox.connect("message_complete", self, "_on_DialogBox_message_complete")
	uiDialogBox.say("Hello world!")
	theDarkness.visible = true
	SaveAndLoad.load_game()


func _on_DialogBox_message_complete():
	uiDialogBox.close()

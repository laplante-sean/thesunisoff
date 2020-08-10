extends Node2D

onready var theDarkness = $TheDarkness


func _ready():
	# We turn visibility off when
	# making levels. This ensures it's always
	# back on for testing
	theDarkness.visible = true
	SaveAndLoad.load_game()

extends Node2D

onready var theDarkness = $TheDarkness


func _ready():
	# We turn visibility off when
	# making levels. This ensures it's always
	# back on for testing
	theDarkness.visible = true
	print("**", PlayerStats.max_health)
	print("**", PlayerStats.health)
	SaveAndLoad.load_game()

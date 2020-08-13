extends Node2D

export(float) var CAMERA_ZOOM_STEP = 0.05
export(float) var MIN_ZOOM = 1
export(float) var MAX_ZOOM = 2

var MainInstances = Utils.get_main_instances()

onready var camera = $Camera2D
onready var theDarkness = $TheDarkness
onready var uiDialogBox = $UI/DialogBox


func _ready():
	# We turn visibility off when
	# making levels. This ensures it's always
	# back on for testing
	MainInstances.dialog = uiDialogBox
	
	# Some test dialog
	Utils.say_dialog(
		"Hello world! Welcome to game. This is a dialog box. It contains dialog. These will pop up and help with things." +
		"You will learn how to play. You will have fun. You will save us from eternal night. You are the hero we need," +
		"but not the one we deserve right now.")

	theDarkness.visible = true
	SaveAndLoad.load_game()


func _physics_process(_delta):
	# TODO - Disable zooming - It's kinda not in the whole 64x64 resolution spirit
	# this is just here for debugging so I can see more stuff when testing.
	if Input.is_action_just_released("zoom_in"):
		zoom_in()
	if Input.is_action_just_released("zoom_out"):
		zoom_out()
	if Input.is_action_just_pressed("reset_camera"):
		print("Reset camera")
		reset_zoom()


func zoom_in():
	zoom(-CAMERA_ZOOM_STEP)


func zoom_out():
	zoom(CAMERA_ZOOM_STEP)


func zoom(step):
	camera.zoom.x = clamp(camera.zoom.x + step, MIN_ZOOM, MAX_ZOOM)
	camera.zoom.y = clamp(camera.zoom.y + step, MIN_ZOOM, MAX_ZOOM)


func reset_zoom():
	camera.zoom = Vector2(1, 1)

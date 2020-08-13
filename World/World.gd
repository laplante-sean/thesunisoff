extends Node2D

export(float) var CAMERA_ZOOM_STEP = 0.05
export(float) var MIN_ZOOM = 1
export(float) var MAX_ZOOM = 2
export(bool) var ZOOMING_ENABLED = false

var MainInstances = Utils.get_main_instances()

onready var camera = $Camera2D
onready var theDarkness = $TheDarkness
onready var uiDialogBox = $UI/DialogBox


func _ready():
	MainInstances.dialog = uiDialogBox
	theDarkness.visible = true
	SaveAndLoad.load_game()


func _physics_process(_delta):
	# TODO - Disable zooming - It's kinda not in the whole 64x64 resolution spirit
	# this is just here for debugging so I can see more stuff when testing.
	if Input.is_action_just_released("zoom_in") and ZOOMING_ENABLED:
		zoom_in()
	if Input.is_action_just_released("zoom_out") and ZOOMING_ENABLED:
		zoom_out()
	if Input.is_action_just_pressed("reset_camera") and ZOOMING_ENABLED:
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

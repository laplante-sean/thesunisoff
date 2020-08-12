extends Node2D

export(float) var CAMERA_ZOOM_STEP = 0.05
export(float) var MIN_ZOOM = 1
export(float) var MAX_ZOOM = 2

onready var camera = $Camera2D
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


func _physics_process(_delta):
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

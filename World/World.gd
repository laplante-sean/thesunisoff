extends Node2D

const Player = preload("res://Player/Player.tscn")

export(String, FILE, "*.tscn") var start_level_path = "res://Levels/Overworld.tscn"
export(float) var CAMERA_ZOOM_STEP = 0.05
export(float) var MIN_ZOOM = 1
export(float) var MAX_ZOOM = 2
export(bool) var ZOOMING_ENABLED = false

var MainInstances = Utils.get_main_instances()
var currentLevelPath = null
var currentLevel = null

onready var camera = $Camera2D
onready var theDarkness = $TheDarkness
onready var uiDialogBox = $UI/DialogBox


func _ready():
	currentLevelPath = start_level_path
	MainInstances.dialog = uiDialogBox
	theDarkness.visible = true
	currentLevel = Utils.instance_scene_on_main(load(currentLevelPath))
	MainInstances.current_level = currentLevel
	SaveAndLoad.load_game()


func _physics_process(_delta):
	if PlayerStats.first_time:
		PlayerStats.first_time = false
		Utils.say_dialog(
			"Welcome! As you may have guessed by the title of the game, " +
			"the sun is off. We would like you to turn it back on. There " +
			"are 4 amulets that you will need to retrieve. Each is hidden " +
			"in one of four dungeons in each of the four corners of the world. " +
			"Go to the dungeons, defeat the monsters, get the amulets and " +
			"combine them to turn the sun back on." 
		)
	
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

extends Node2D

export(float) var CAMERA_ZOOM_STEP = 0.05
export(float) var MIN_ZOOM = 1
export(float) var MAX_ZOOM = 2
export(bool) var ZOOMING_ENABLED = false

var MainInstances = Utils.get_main_instances()

onready var camera = $Camera
onready var theDarkness = $TheDarkness
onready var playerTorch = $PlayerTorch
onready var uiDialogBox = $UI/DialogBox
onready var youwin = $YouWin
onready var welcomeMessageTimer = $WelcomeMessageTimer


func _ready():
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	Events.connect("win_the_game", self, "_on_Events_win_the_game")
	Events.connect("next_level", self, "_on_Events_next_level")
	Events.connect("amulet_collected", self, "_on_Events_amulet_collected")
	Events.connect("level_loaded", self, "_on_Events_level_loaded")
	SaveAndLoad.connect("let_there_be_light", self, "_on_SaveAndLoad_let_there_be_light")
	MainInstances.dialog = uiDialogBox
	theDarkness.visible = true
	SaveAndLoad.load_game()


func _on_joy_connection_changed(device_id, connected):
	if connected:
		print("New input: ", Input.get_joy_name(device_id))
	else:
		print("Keyboard/mouse")


func _physics_process(_delta):
	if Input.is_action_just_released("zoom_in") and ZOOMING_ENABLED:
		zoom_in()
	if Input.is_action_just_released("zoom_out") and ZOOMING_ENABLED:
		zoom_out()
	if Input.is_action_just_pressed("reset_camera") and ZOOMING_ENABLED:
		reset_zoom()
		
	if Input.is_action_just_pressed("light"):
		playerTorch.visible = !playerTorch.visible


func zoom_in():
	zoom(-CAMERA_ZOOM_STEP)


func zoom_out():
	zoom(CAMERA_ZOOM_STEP)


func zoom(step):
	camera.zoom.x = clamp(camera.zoom.x + step, MIN_ZOOM, MAX_ZOOM)
	camera.zoom.y = clamp(camera.zoom.y + step, MIN_ZOOM, MAX_ZOOM)


func reset_zoom():
	camera.zoom = Vector2(1, 1)


func _on_SaveAndLoad_let_there_be_light():
	theDarkness.visible = false


func _on_Events_win_the_game():
	youwin.pause = true
	if SaveAndLoad.save_data != null:
		SaveAndLoad.save_data.darkness = false
	theDarkness.visible = false
	SaveAndLoad.save_game()


func _on_Events_level_loaded(level_id):
	if PlayerStats.first_time and level_id == "overworld":
		PlayerStats.first_time = false
		PlayerStats.tutorial_complete = true
		welcomeMessageTimer.start()
		SaveAndLoad.save_game()


func _on_Events_next_level(path):
	SaveAndLoad.call_deferred("load_level", path)


func _on_Events_amulet_collected(type):
	SaveAndLoad.mark_overworld_enemies_undefeated()


func _on_WelcomeMessageTimer_timeout():
	Utils.call_deferred("say_dialog",
		"Welcome! As you may have guessed by the title of the game, " +
		"the sun is off. We would like you to turn it back on. There " +
		"are 4 amulets that you will need to retrieve. Each is hidden " +
		"in one of four dungeons in each of the four corners of the world. " +
		"Go to the dungeons, defeat the monsters, get the amulets and " +
		"combine them to turn the sun back on." 
	)

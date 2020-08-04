extends KinematicBody2D
class_name Player

export(int) var ACCELERATION = 200
export(int) var MAX_SPEED = 45
export(int) var FRICTION = 220

enum {
	MOVE,
	PUNCH
}

var state = MOVE
var punch_animation = "Punch"
var velocity = Vector2.ZERO

var MainInstances = ResourceLoader.load("res://maininstances/MainInstances.tres")

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")


func _ready():
	animationTree.active = true


func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		PUNCH:
			attack_state()


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Punch/blend_position", input_vector)
		animationTree.set("parameters/PunchAlt/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if Input.is_action_just_pressed("punch"):
		punch_animation = "Punch"
		state = PUNCH

	move()


func attack_state():
	velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("punch"):
		# They pressed attack again
		punch_animation = "PunchAlt"

	animationState.travel(punch_animation)

func attack_animation_finished():
	state = MOVE


func move():
	velocity = move_and_slide(velocity)

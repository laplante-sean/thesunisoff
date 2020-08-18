extends KinematicBody2D
class_name NPC

signal interacted_with()

export(int) var ACCELERATION = 100
export(int) var MAX_SPEED = 30
export(int) var FRICTION = 200
export(int) var WANDER_MIN_TIME = 1
export(int) var WANDER_MAX_TIME = 3
export(int) var WANDER_TARGET_RANGE = 4
export(bool) var INTERACT_WITH_QUESTION = false
export(bool) var WIN_WITH_ALL_AMULETS = false
export(String) var INTERACTION_TEXT = ""
export(String) var INTERACTION_Q_POSITIVE_RESPONSE = ""
export(String) var INTERACTION_Q_NEGATIVE_RESPONSE = ""
export(String) var ALL_THE_AMULETS_MESSAGE = ""

enum NPCState {
	IDLE,
	WANDER,
	PLAYER_DETECTED
}

var velocity = Vector2.ZERO
var state = NPCState.IDLE

onready var sprite = $AnimatedSprite
onready var playerDetectionZone = $PlayerDetectionZone
onready var wanderController = $WanderController


func _ready():
	set_physics_process(false)
	state = pick_random_state([NPCState.IDLE, NPCState.WANDER])
	Events.connect("yesno_answer", self, "_on_Events_yesno_answer")
	Events.connect("dialog_complete", self, "_on_Events_dialog_complete")


func _physics_process(delta):
	match state:
		NPCState.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			check_and_update_state()
		NPCState.WANDER:
			seek_player()
			check_and_update_state()
			move_toward_position(wanderController.target_position, delta)
			sprite.flip_h = velocity.x < 0

			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				state = pick_random_state([NPCState.IDLE, NPCState.WANDER])
				wanderController.start_wander_timer(rand_range(WANDER_MIN_TIME, WANDER_MAX_TIME))
		NPCState.PLAYER_DETECTED:
			player_detected(delta)
			sprite.flip_h = velocity.x < 0

	velocity = move_and_slide(velocity)


func player_detected(_delta):
	# This method should be overidden to customize NPC behavior when near
	# the player
	var player = playerDetectionZone.player
	if player == null:
		state = NPCState.IDLE

func seek_player():
	if playerDetectionZone.can_see_player():
		state = NPCState.PLAYER_DETECTED


func move_toward_position(pos, delta):
	var direction = global_position.direction_to(pos)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)


func check_and_update_state():
	if wanderController.get_time_left() == 0:
		state = pick_random_state([NPCState.IDLE, NPCState.WANDER])
		wanderController.start_wander_timer(rand_range(WANDER_MIN_TIME, WANDER_MAX_TIME))


func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()


func interact():
	if PlayerStats.has_all_four_amulets() and len(ALL_THE_AMULETS_MESSAGE) > 0:
		Utils.say_dialog(ALL_THE_AMULETS_MESSAGE)
		return
	
	if len(INTERACTION_TEXT) > 0 and not INTERACT_WITH_QUESTION:
		Utils.say_dialog(INTERACTION_TEXT)
	elif len(INTERACTION_TEXT) > 0 and INTERACT_WITH_QUESTION:
		Utils.ask_dialog(INTERACTION_TEXT)

	emit_signal("interacted_with")


func _on_Events_yesno_answer(question, answer):
	if question != INTERACTION_TEXT:
		return

	if answer:
		Utils.call_deferred("say_dialog", INTERACTION_Q_POSITIVE_RESPONSE)
	else:
		Utils.call_deferred("say_dialog", INTERACTION_Q_NEGATIVE_RESPONSE)


func _on_VisibilityEnabler2D_screen_entered():
	set_physics_process(true)


func _on_VisibilityEnabler2D_screen_exited():
	set_physics_process(false)


func _on_Events_dialog_complete(message):
	if PlayerStats.has_all_four_amulets() and len(ALL_THE_AMULETS_MESSAGE) > 0 and message == ALL_THE_AMULETS_MESSAGE and WIN_WITH_ALL_AMULETS:
		Events.emit_signal("win_the_game")

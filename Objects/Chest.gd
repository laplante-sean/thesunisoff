extends "res://Objects/InteractibleObject.gd"

const Coin = preload("res://Items/Coin.tscn")

enum ChestState {
	LOCKED,
	UNLOCKED,
	OPEN
}

export(ChestState) var STARTING_STATE = ChestState.LOCKED

var state = ChestState.LOCKED setget set_state

onready var animationPlayer = $AnimationPlayer


func _ready():
	self.state = STARTING_STATE


func set_state(value):
	state = value
	
	match state:
		ChestState.LOCKED:
			sprite.frame = 0
		ChestState.UNLOCKED:
			sprite.frame = 1
		ChestState.OPEN:
			sprite.frame = 5


func interact():
	print("Interact with chest!")
	
	match state:
		ChestState.LOCKED:
			print("Sorry, the chest is locked. You need a key")
		ChestState.UNLOCKED:
			animationPlayer.play("Open")
		ChestState.OPEN:
			print("Already open")


func _on_AnimationPlayer_animation_finished(anim_name):
	self.state = ChestState.OPEN
	
	# TODO - Somehow have chests with different items
	for i in range(int(rand_range(10, 20))):
		Utils.instance_scene_on_main(Coin, global_position)

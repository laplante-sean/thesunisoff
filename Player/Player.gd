extends KinematicBody2D
class_name Player

const ExplodeEffect = preload("res://Effects/ExplodeEffect.tscn")
const Potion = preload("res://Player/Potion.tscn")

export(int) var ACCELERATION = 200
export(int) var MAX_SPEED = 45
export(int) var FRICTION = 220
export(float) var INVINCIBILITY_TIME = 0.6

enum PlayerState {
	MOVE,
	ATTACK,
	THROW
}

var state = PlayerState.MOVE
var spell_animation = "Spell" setget set_spell_animation, get_spell_animation
var velocity = Vector2.ZERO
var stats = PlayerStats
var player_facing = Vector2.DOWN

onready var hurtbox = $Hurtbox
onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var animationTree = $AnimationTree
onready var spellKnockbackHitbox = $Pivot/SpellKnockbackHitbox
onready var swordKnockbackHitbox = $Pivot/SwordKnockbackHitbox
onready var hurtboxCollider = $Hurtbox/Collider
onready var spellKnockbackCollider = $Pivot/SpellKnockbackHitbox/Collider
onready var swordKnockbackCollider = $Pivot/SwordKnockbackHitbox/Collider
onready var spell360KnockbackCollider = $Spell360KnockbackHitbox/Collider
onready var throwPotionTimer = $ThrowPotionTimer
onready var potionSpawn = $Pivot/PotionSpawn
onready var animationState = animationTree.get("parameters/playback")


func _ready():
	stats.connect("no_health", self, "_on_PlayerStats_no_health")
	animationTree.active = true
	spellKnockbackHitbox.knockback_vector = Vector2.DOWN
	swordKnockbackHitbox.knockback_vector = Vector2.DOWN
	
	# set the correct initial states for colliders
	hurtboxCollider.disabled = false
	spellKnockbackCollider.disabled = true
	swordKnockbackCollider.disabled = true
	spell360KnockbackCollider.disabled = true
	
	# We start facing down
	set_facing(player_facing)


func _physics_process(delta):
	match state:
		PlayerState.MOVE:
			move_state(delta)
		PlayerState.ATTACK:
			velocity = Vector2.ZERO
		PlayerState.THROW:
			velocity = Vector2.ZERO


func set_facing(vec):
	player_facing = vec
	spellKnockbackHitbox.knockback_vector = vec
	swordKnockbackHitbox.knockback_vector = vec
	animationTree.set("parameters/Idle/blend_position", vec)
	animationTree.set("parameters/Run/blend_position", vec)
	animationTree.set("parameters/Spell/blend_position", vec)
	animationTree.set("parameters/SpellAlt/blend_position", vec)
	animationTree.set("parameters/SpellCast360/blend_position", vec)
	animationTree.set("parameters/Sword/blend_position", vec)
	animationTree.set("parameters/Throw/blend_position", vec)


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		set_facing(input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if Input.is_action_just_pressed("cast_spell"):
		animationState.travel(self.spell_animation)
		state = PlayerState.ATTACK
	elif Input.is_action_just_pressed("cast_spell_360"):
		animationState.travel("SpellCast360")
		state = PlayerState.ATTACK
	elif Input.is_action_just_pressed("throw_potion") and throwPotionTimer.time_left == 0:
		if Input.is_action_pressed("throw_behind_modifier"):
			throw_potion(true)
		else:
			animationState.travel("Throw")
			state = PlayerState.THROW
	elif Input.is_action_just_pressed("sword_attack"):
		animationState.travel("Sword")
		state = PlayerState.ATTACK

	move()


func throw_potion(behind=false):
	var direction = player_facing
	var pos = potionSpawn.global_position

	if behind:
		direction *= -1
		pos = global_position

	var potion = Utils.instance_scene_on_main(Potion, pos)
	
	if behind:
		potion.FLIGHT_TIME = 0.05
		potion.SPEED /= 3
	
	potion.velocity = direction
	throwPotionTimer.start()


func set_spell_animation(value):
	spell_animation = value


func get_spell_animation():
	# Auto-alternate the punching animation
	var ret = spell_animation
	if ret == "Spell":
		spell_animation = "SpellAlt"
	else:
		spell_animation = "Spell"
	return ret


func attack_animation_finished():
	if state == PlayerState.THROW:
		throw_potion()
	state = PlayerState.MOVE


func move():
	velocity = move_and_slide(velocity)


func _on_PlayerStats_no_health():
	queue_free()
	Utils.instance_scene_on_main(ExplodeEffect, sprite.global_position)


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(INVINCIBILITY_TIME)
	hurtbox.create_hit_effect()


func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("StartFlash")


func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("StopFlash")

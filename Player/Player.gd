extends KinematicBody2D
class_name Player

const DeathEffect = preload("res://Effects/DeathEffect.tscn")

export(int) var ACCELERATION = 200
export(int) var MAX_SPEED = 45
export(int) var FRICTION = 220
export(float) var INVINCIBILITY_TIME = 0.6

enum {
	MOVE,
	ATTACK
}

var state = MOVE
var spell_animation = "Spell" setget set_spell_animation, get_spell_animation
var velocity = Vector2.ZERO
var stats = PlayerStats

onready var hurtbox = $Hurtbox
onready var animationPlayer = $AnimationPlayer
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var animationTree = $AnimationTree
onready var spellKnockbackHitbox = $HitboxPivot/SpellKnockbackHitbox
onready var animationState = animationTree.get("parameters/playback")


func _ready():
	stats.connect("no_health", self, "_on_PlayerStats_no_health")
	animationTree.active = true
	spellKnockbackHitbox.knockback_vector = Vector2.DOWN


func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			velocity = Vector2.ZERO


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		spellKnockbackHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Spell/blend_position", input_vector)
		animationTree.set("parameters/SpellAlt/blend_position", input_vector)
		animationTree.set("parameters/SpellCast360/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if Input.is_action_just_pressed("cast_spell"):
		animationState.travel(self.spell_animation)
		state = ATTACK
	elif Input.is_action_just_pressed("cast_spell_360"):
		animationState.travel("SpellCast360")
		state = ATTACK
	elif Input.is_action_just_pressed("throw_potion"):
		pass

	move()


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
	state = MOVE


func move():
	velocity = move_and_slide(velocity)


func _on_PlayerStats_no_health():
	queue_free()
	Utils.instance_scene_on_main(DeathEffect, global_position)


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(INVINCIBILITY_TIME)
	hurtbox.create_hit_effect()


func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("StartFlash")


func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("StopFlash")

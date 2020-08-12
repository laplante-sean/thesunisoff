extends Area2D
class_name Hurtbox

const HitEffect = preload("res://Effects/HitEffect.tscn")

var invincible = false setget set_invincible
var inside_hitbox = null

onready var invincibilityTimer = $InvincibilityTimer

signal invincibility_started
signal invincibility_ended
signal take_damage(area)
signal end_movement_buf(area)


func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")
		if inside_hitbox != null and inside_hitbox.PERSIST_DAMAGE:
			emit_signal("take_damage", inside_hitbox)


func start_invincibility(duration):
	self.invincible = true
	invincibilityTimer.start(duration)


func create_hit_effect():
	Utils.instance_scene_on_main(HitEffect, global_position)


func _on_Hurtbox_area_entered(area):
	if area is Hitbox:
		inside_hitbox = area

		if not self.invincible:
			emit_signal("take_damage", area)


func _on_Hurtbox_area_exited(area):
	if area is Hitbox:
		inside_hitbox = null
		emit_signal("end_movement_buf", area)


func _on_InvincibilityTimer_timeout():
	self.invincible = false

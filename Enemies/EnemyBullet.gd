extends "res://Player/Projectile.gd"

const HitEffect = preload("res://Effects/HitEffect.tscn")


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Hitbox_body_entered(body):
	# Collided with world
	Utils.instance_scene_on_main(HitEffect, global_position)
	queue_free()


func _on_Hitbox_area_entered(area):
	# Collided with a hurtbox
	queue_free()

extends "res://Player/Projectile.gd"


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Hitbox_body_entered(body):
	queue_free()


func _on_Hitbox_area_entered(area):
	queue_free()

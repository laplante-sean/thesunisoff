extends AnimatedSprite

const HitEffectSound = preload("res://Audio/HitEffectSound.tscn")

func _ready():
	frame = 0
	Utils.instance_scene_on_main(HitEffectSound, global_position)
	connect("animation_finished", self, "_on_animation_finished")
	play("Animate")

func _on_animation_finished():
	queue_free()

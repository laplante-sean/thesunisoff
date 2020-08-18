extends StaticBody2D
class_name InteractibleObject

signal interacted_with(object)

onready var sprite = $Sprite
onready var collider = $Collider
onready var occluder = $LightOccluder2D


func interact():
	"""
	Sub-classes must override this to handle interaction
	"""
	emit_signal("interacted_with", self)

extends StaticBody2D
class_name InteractibleObject

onready var sprite = $Sprite
onready var collider = $Collider
onready var occluder = $LightOccluder2D


func interact():
	"""
	Sub-classes must override this to handle interaction
	"""
	print("Interact with: ", self)

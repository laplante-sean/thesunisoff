extends StaticBody2D
class_name InteractibleObject

onready var sprite = $Sprite


func interact():
	"""
	Sub-classes must override this to handle interaction
	"""
	print("Interact with: ", self)

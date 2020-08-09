extends Node2D

export(int) var SPEED = 35

var velocity = Vector2.ZERO

onready var sprite = $AnimatedSprite


func _process(delta):
	sprite.flip_h = velocity.x < 0
	
	if velocity.y < 0:
		sprite.rotation_degrees = -90
	if velocity.y > 0:
		sprite.rotation_degrees = 90

	position += velocity * SPEED * delta

extends KinematicBody2D

export(int) var SPEED = 55

var velocity = Vector2.ZERO setget set_velocity

onready var sprite = $AnimatedSprite
onready var shadowSprite = $ShadowSprite


func _physics_process(delta):
	sprite.flip_h = velocity.x < 0
	
	if velocity.y < 0:
		sprite.rotation_degrees = -90
	if velocity.y > 0:
		sprite.rotation_degrees = 90

	var collision = move_and_collide(velocity * delta)
	if collision != null:
		velocity = Vector2.ZERO


func set_velocity(value):
	velocity = value * SPEED

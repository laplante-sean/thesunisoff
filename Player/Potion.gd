extends "res://Player/Projectile.gd"

enum PotionType { 
	FIRE,
	ICE
}

enum PotionState {
	FLY,
	EXPLODE,
	LINGER,
	DISOLVE
}

export(PotionType) var POTION_TYPE = PotionType.FIRE
export(int) var FLIGHT_DISTANCE = 20
export(int) var IMPACT_RADIUS = 10
export(float) var LINGER_TIME = 5

var state = PotionState.FLY
var fly_animation = "Fire"
var explode_animation = "ExplodeFire"
var linger_animation = "LingerFire"
var disolve_animation = "DisolveFire"
var spawn_point = Vector2.ZERO

onready var lingerTimer = $LingerTimer
onready var hitboxCollider = $Hitbox/Collider


func _ready():
	spawn_point = global_position
	hitboxCollider.disabled = true
	hitboxCollider.shape.radius = IMPACT_RADIUS
	lingerTimer.wait_time = LINGER_TIME

	match POTION_TYPE:
		PotionType.FIRE:
			fly_animation = "Fire"
			explode_animation = "ExplodeFire"
			linger_animation = "LingerFire"
			disolve_animation = "DisolveFire"
		PotionType.ICE:
			fly_animation = "Ice"
			explode_animation = "ExplodeIce"
			linger_animation = "LingerIce"
			disolve_animation = "DisolveIce"


func _process(delta):

	match state:
		PotionState.FLY:
			sprite.animation = fly_animation
			if abs(global_position.distance_to(spawn_point)) >= FLIGHT_DISTANCE:
				state = PotionState.EXPLODE
		PotionState.EXPLODE:
			sprite.animation = explode_animation
			hitboxCollider.disabled = false
			velocity = Vector2.ZERO
		PotionState.LINGER:
			sprite.animation = linger_animation
		PotionState.DISOLVE:
			hitboxCollider.disabled = true
			sprite.animation = disolve_animation


func _on_AnimatedSprite_animation_finished():
	if state == PotionState.EXPLODE:
		state = PotionState.LINGER
		lingerTimer.start()
	if state == PotionState.DISOLVE:
		queue_free()  # Remove when the disolve animation is complete


func _on_LingerTimer_timeout():
	state = PotionState.DISOLVE

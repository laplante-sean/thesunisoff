extends Projectile
class_name ProjectilePotion

const ExplodeEffect = preload("res://Effects/ExplodeEffect.tscn")
const FireLight = preload("res://Effects/FireLight.tscn")   # For fire potion
const IceLight = preload("res://Effects/IceLight.tscn")      # For ice potion

enum PotionState {
	FLY,
	EXPLODE,
	IGNITE,
	LINGER,
	DISOLVE
}

export(float) var FLIGHT_TIME = 0.3
export(int) var IMPACT_RADIUS = 5
export(float) var LINGER_TIME = 5

var state = PotionState.FLY
var type = Potion.PotionType.FIRE setget set_type
var fly_animation = "Fire"
var ignite_animation = "IgniteFire"
var linger_animation = "LingerFire"
var disolve_animation = "DisolveFire"
var lighting = null

onready var lingerTimer = $LingerTimer
onready var flightTimer = $FlightTimer
onready var hitboxCollider = $Hitbox/Collider
onready var hitbox = $Hitbox


func _ready():
	hitboxCollider.disabled = true
	hitboxCollider.shape.radius = IMPACT_RADIUS
	lingerTimer.wait_time = LINGER_TIME
	flightTimer.wait_time = FLIGHT_TIME
	flightTimer.start()


func set_type(value):
	type = value

	if lighting != null:
		lighting.queue_free()

	match type:
		Potion.PotionType.FIRE:
			fly_animation = "Fire"
			ignite_animation = "IgniteFire"
			linger_animation = "LingerFire"
			disolve_animation = "DisolveFire"
			lighting = FireLight.instance()
			hitbox.MOVEMENT_BUF = 0.75
		Potion.PotionType.ICE:
			fly_animation = "Ice"
			ignite_animation = "IgniteIce"
			linger_animation = "LingerIce"
			disolve_animation = "DisolveIce"
			lighting = IceLight.instance()
			hitbox.MOVEMENT_BUF = 0.2
	
	add_child(lighting)


func _physics_process(delta):

	match state:
		PotionState.FLY:
			sprite.animation = fly_animation
		PotionState.EXPLODE:
			shadowSprite.visible = false
			sprite.visible = false
			hitboxCollider.disabled = false
			velocity = Vector2.ZERO
		PotionState.IGNITE:
			sprite.rotation_degrees = 0
			sprite.visible = true
			sprite.animation = ignite_animation
		PotionState.LINGER:
			sprite.animation = linger_animation
		PotionState.DISOLVE:
			hitboxCollider.disabled = true
			sprite.animation = disolve_animation


func _on_ExplodeEffect_animation_finished():
	state = PotionState.IGNITE


func _on_AnimatedSprite_animation_finished():
	if state == PotionState.IGNITE:
		state = PotionState.LINGER
		lingerTimer.start()
	if state == PotionState.DISOLVE:
		queue_free()  # Remove when the disolve animation is complete


func _on_LingerTimer_timeout():
	state = PotionState.DISOLVE


func _on_FlightTimer_timeout():
	state = PotionState.EXPLODE
	create_explosion()


func create_explosion():
	var explosion = Utils.instance_scene_on_main(ExplodeEffect, sprite.global_position)
	explosion.connect("animation_finished", self, "_on_ExplodeEffect_animation_finished")


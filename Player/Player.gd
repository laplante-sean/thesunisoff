extends KinematicBody2D
class_name Player

const ExplodeEffect = preload("res://Effects/ExplodeEffect.tscn")
const ProjectilePotionScene = preload("res://Player/ProjectilePotion.tscn")
const LevelUpSound = preload("res://Audio/LevelUpSound.tscn")
const SwipeSound = preload("res://Audio/SwipeSound.tscn")

export(int) var ACCELERATION = 400
export(int) var MAX_SPEED = 45
export(int) var FRICTION = 400
export(int) var INTERACT_DISTANCE = 4
export(float) var INVINCIBILITY_TIME = 0.6
export(float) var LEVEL_UP_INVINCIBILITY_TIME = 5
export(int) var SPELL_360_MAGIC_COST = 50
export(int) var SPELL_MAGIC_COST = 25

enum PlayerState {
	MOVE,
	ATTACK,
	THROW,
	SUCCESS
}


enum EquipedPotion {
	NONE,
	HEALTH,
	FIRE,
	ICE
}

var potion = EquipedPotion.NONE setget set_potion
var state = PlayerState.MOVE
var spell_animation = "Spell" setget set_spell_animation, get_spell_animation
var velocity = Vector2.ZERO
var stats = PlayerStats
var player_facing = Vector2.DOWN
var queued_locked_interactible = null

onready var cameraFollow = $CameraFollow
onready var lightFollow = $LightFollow
onready var hurtbox = $Hurtbox
onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var animationTree = $AnimationTree
onready var spellHitbox = $Pivot/SpellHitbox
onready var swordHitbox = $Pivot/SwordHitbox
onready var spell360Hitbox = $Spell360Hitbox
onready var hurtboxCollider = $Hurtbox/Collider
onready var spellCollider = $Pivot/SpellHitbox/Collider
onready var swordCollider = $Pivot/SwordHitbox/Collider
onready var spell360Collider = $Spell360Hitbox/Collider
onready var throwPotionTimer = $ThrowPotionTimer
onready var potionSpawn = $Pivot/PotionSpawn
onready var interactionRay = $InteractionRay
onready var footstepsFloor = $FootstepsFloor
onready var particles = $Particles2D
onready var animationState = animationTree.get("parameters/playback")


func _ready():
	Events.connect("yesno_answer", self, "_on_Events_yesno_answer")
	stats.connect("boost_attack_strength", self, "_on_PlayerStats_boost_attack_strength")
	stats.connect("no_health", self, "_on_PlayerStats_no_health")
	stats.connect("level_up", self, "_on_PlayerStats_level_up")
	stats.connect("sword_knockback_changed", self, "_on_PlayerStats_sword_knockback_changed")
	stats.connect("spell_knockback_changed", self, "_on_PlayerStats_spell_knockback_changed")
	stats.connect("spell_360_knockback_changed", self, "_on_PlayerStats_spell_360_knockback_changed")
	animationTree.active = true
	spellHitbox.knockback_vector = Vector2.DOWN
	swordHitbox.knockback_vector = Vector2.DOWN
	
	# set the correct initial states for colliders
	reset_colliders()
	
	# We start facing down
	set_facing(player_facing)

	var mat = sprite.get_material()
	mat.set_shader_param("active", false)

	spellHitbox.DAMAGE += PlayerStats.weapon_hitpoint_boost
	spell360Hitbox.DAMAGE += PlayerStats.weapon_hitpoint_boost
	swordHitbox.DAMAGE += PlayerStats.weapon_hitpoint_boost


func _on_PlayerStats_boost_attack_strength(value):
	spellHitbox.DAMAGE += 1
	spell360Hitbox.DAMAGE += 1 
	swordHitbox.DAMAGE += 1


func reset_colliders():
	hurtboxCollider.disabled = false
	spellCollider.disabled = true
	swordCollider.disabled = true
	spell360Collider.disabled = true


func _physics_process(delta):
	if self.potion == EquipedPotion.NONE:
		if PlayerStats.has_item(ItemUtils.get_item_id("HealthPotion")):
			self.potion = EquipedPotion.HEALTH
		elif PlayerStats.has_item(ItemUtils.get_item_id("FirePotion")):
			self.potion = EquipedPotion.FIRE
		elif PlayerStats.has_item(ItemUtils.get_item_id("IcePotion")):
			self.potion = EquipedPotion.ICE
	
	match state:
		PlayerState.MOVE:
			move_state(delta)
		PlayerState.ATTACK:
			stop_walking_sound()
			velocity = Vector2.ZERO
		PlayerState.THROW:
			stop_walking_sound()
			velocity = Vector2.ZERO
		PlayerState.SUCCESS:
			stop_walking_sound()
			velocity = Vector2.ZERO


func set_facing(vec):
	player_facing = vec
	spellHitbox.knockback_vector = vec
	swordHitbox.knockback_vector = vec
	interactionRay.cast_to = vec
	interactionRay.scale.x = INTERACT_DISTANCE
	interactionRay.scale.y = INTERACT_DISTANCE
	animationTree.set("parameters/Idle/blend_position", vec)
	animationTree.set("parameters/Run/blend_position", vec)
	animationTree.set("parameters/Spell/blend_position", vec)
	animationTree.set("parameters/SpellAlt/blend_position", vec)
	animationTree.set("parameters/SpellCast360/blend_position", vec)
	animationTree.set("parameters/Sword/blend_position", vec)
	animationTree.set("parameters/Throw/blend_position", vec)
	animationTree.set("parameters/Success/blend_position", vec)


func get_potion_item_id(value):
	var item = null

	match value:
		EquipedPotion.HEALTH:
			item = ItemUtils.get_item_id("HealthPotion")
		EquipedPotion.FIRE:
			item = ItemUtils.get_item_id("FirePotion")
		EquipedPotion.ICE:
			item = ItemUtils.get_item_id("IcePotion")

	return item


func set_potion(value):
	if value <= 0:
		value = EquipedPotion.ICE
	elif value > EquipedPotion.ICE:
		value = EquipedPotion.HEALTH

	var item = get_potion_item_id(value)
	var found = true

	if item != null and not PlayerStats.has_item(item):
		found = false
		var nxt_item = value + 1
		while not found:
			if nxt_item > EquipedPotion.ICE:
				nxt_item = 1
			if nxt_item == value:
				break
			
			if PlayerStats.has_item(get_potion_item_id(nxt_item)):
				found = true
				value = nxt_item
				break
			
			nxt_item += 1
	
	if not found:
		potion = EquipedPotion.NONE
	else:
		potion = value

	Events.emit_signal("equip_potion", potion)


func play_walking_sound():
	if not footstepsFloor.is_playing():
		footstepsFloor.play()


func stop_walking_sound():
	footstepsFloor.stop()


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		set_facing(input_vector)
		play_walking_sound()
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		stop_walking_sound()
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if Input.is_action_just_pressed("cast_spell") and PlayerStats.magic >= SPELL_MAGIC_COST:
		PlayerStats.magic -= SPELL_MAGIC_COST
		animationState.travel(self.spell_animation)
		state = PlayerState.ATTACK
	elif Input.is_action_just_pressed("cast_spell_360") and PlayerStats.magic >= SPELL_360_MAGIC_COST:
		PlayerStats.magic -= SPELL_360_MAGIC_COST
		animationState.travel("SpellCast360")
		state = PlayerState.ATTACK
	elif Input.is_action_just_pressed("throw_potion") and throwPotionTimer.time_left == 0 and potion != EquipedPotion.NONE:
		if Input.is_action_pressed("throw_behind_modifier"):
			throw_potion(true)
		else:
			throw_potion()
	elif Input.is_action_just_pressed("sword_attack"):
		animationState.travel("Sword")
		Utils.instance_scene_on_main(SwipeSound, global_position)
		state = PlayerState.ATTACK
	elif Input.is_action_just_pressed("interact"):
		interact()
	elif Input.is_action_just_pressed("next_potion"):
		self.potion += 1
	elif Input.is_action_just_pressed("prev_potion"):
		self.potion -= 1
	elif Input.is_action_just_pressed("equip_health") and PlayerStats.has_item(ItemUtils.get_item_id("HealthPotion")):
		self.potion = EquipedPotion.HEALTH
	elif Input.is_action_just_pressed("equip_fire") and PlayerStats.has_item(ItemUtils.get_item_id("FirePotion")):
		self.potion = EquipedPotion.FIRE
	elif Input.is_action_just_pressed("equip_ice") and PlayerStats.has_item(ItemUtils.get_item_id("IcePotion")):
		self.potion = EquipedPotion.ICE
	elif Input.is_action_just_pressed("inventory"):
		PlayerStats.describe_inventory()
	elif Input.is_action_just_pressed("display_stats"):
		PlayerStats.describe_stats()

	move()


func throw_potion(behind=false):
	var throw_type = Potion.PotionType.FIRE
	
	match self.potion:
		EquipedPotion.NONE:
			return
		EquipedPotion.HEALTH:
			if PlayerStats.health < PlayerStats.max_health:
				var health_potion = PlayerStats.use_item(ItemUtils.get_item_id("HealthPotion"))
				if health_potion == null:
					return
				PlayerStats.health += health_potion.restore_health_points

			if not PlayerStats.has_item(ItemUtils.get_item_id("HealthPotion")):
				self.potion = EquipedPotion.NONE
			return
		EquipedPotion.FIRE:
			var fire_potion = PlayerStats.use_item(ItemUtils.get_item_id("FirePotion"))
			if fire_potion == null:
				return
			throw_type = Potion.PotionType.FIRE
			if not PlayerStats.has_item(ItemUtils.get_item_id("FirePotion")):
				self.potion = EquipedPotion.NONE
		EquipedPotion.ICE:
			var ice_potion = PlayerStats.use_item(ItemUtils.get_item_id("IcePotion"))
			if ice_potion == null:
				return
			throw_type = Potion.PotionType.ICE
			if not PlayerStats.has_item(ItemUtils.get_item_id("IcePotion")):
				self.potion = EquipedPotion.NONE
	
	var direction = player_facing
	var pos = potionSpawn.global_position

	if behind:
		direction *= -1
		pos = global_position

	var potion_instance = Utils.instance_scene_on_main(ProjectilePotionScene, pos)
	potion_instance.type = throw_type
	
	if behind:
		potion_instance.FLIGHT_TIME = 0.05
		potion_instance.SPEED /= 3
	
	potion_instance.velocity = direction
	throwPotionTimer.start()


func interact():
	var object = interactionRay.get_collider()
	if object == null or (not object is InteractibleObject and not object is NPC):
		print("No interaction on ", object)
		return
	if queued_locked_interactible != null:
		return

	if object is Chest and object.is_locked() and object.UNLOCK_WITH_KEY:
		if stats.has_item(ItemUtils.get_item_id("ChestKey")):
			queued_locked_interactible = object
			Utils.ask_dialog("Use 1 chest key to unlock the chest?")
			return
	elif object is Door and object.is_locked() and object.UNLOCK_WITH_KEY:
		if stats.has_item(ItemUtils.get_item_id("DoorKey")):
			queued_locked_interactible = object
			Utils.ask_dialog("Use 1 door key to unlock the door?")
			return

	object.interact()


func _on_PlayerStats_sword_knockback_changed(value):
	swordHitbox.KNOCKBACK_FACTOR = value


func _on_PlayerStats_spell_knockback_changed(value):
	spellHitbox.KNOCKBACK_FACTOR = value


func _on_PlayerStats_spell_360_knockback_changed(value):
	spell360Hitbox.KNOCKBACK_FACTOR = value


func _on_Events_yesno_answer(question, answer):
	if queued_locked_interactible == null:
		return
	
	if queued_locked_interactible is Chest and answer:
		stats.use_item(ItemUtils.get_item_id("ChestKey"))
		queued_locked_interactible.unlock()
	elif queued_locked_interactible is Door and answer:
		stats.use_item(ItemUtils.get_item_id("DoorKey"))
		queued_locked_interactible.unlock()
		
	if answer:
		queued_locked_interactible.interact()
	
	queued_locked_interactible = null

func set_spell_animation(value):
	spell_animation = value


func get_spell_animation():
	# Auto-alternate the punching animation
	var ret = spell_animation
	if ret == "Spell":
		spell_animation = "SpellAlt"
	else:
		spell_animation = "Spell"
	return ret


func attack_animation_finished():
	if state == PlayerState.THROW:
		throw_potion()
	state = PlayerState.MOVE


func success_animation_finished():
	reset_colliders()  # Level up can happen mid-attack leaving our hitboxes on
	state = PlayerState.MOVE


func level_up_explosion():
	particles.emitting = true


func move():
	velocity = move_and_slide(velocity)


func _on_PlayerStats_no_health():
	queue_free()
	Utils.instance_scene_on_main(ExplodeEffect, sprite.global_position)


func _on_PlayerStats_level_up():
	print("Level up")
	state = PlayerState.SUCCESS
	animationState.travel("Success")
	hurtbox.start_invincibility(LEVEL_UP_INVINCIBILITY_TIME)
	Utils.instance_scene_on_main(LevelUpSound, global_position)


func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("StartFlash")


func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("StopFlash")


func _on_Hurtbox_take_damage(area):
	stats.health -= area.DAMAGE
	hurtbox.start_invincibility(INVINCIBILITY_TIME)
	hurtbox.create_hit_effect()


func _on_ItemCollector_body_entered(body):
	var data = null
	if body is CollectibleItem:
		data = body.collect()
	
	if data == null:
		print("Error: No data collected from item: ", body)
		return
		
	if body.IS_MONEY:
		stats.money += data.value
	else:
		stats.collect_item(data)
	
	body.queue_free()

extends Position2D
class_name NPCSpawner

export(String, FILE, "*.tscn") var SPAWN_NPC = "res://NPC/Bird.tscn"
export(int) var MIN_QUANTITY = 3
export(int) var MAX_QUANTITY = 5
export(bool) var RESPAWN_ONCE_DEAD = true  # respawn when all are dead
export(bool) var DEFEATABLE = false
export(int) var SPREAD_RADIUS = 10

signal defeated

var dead = 0
var spawn = 0
var defeated = false
var spawned = false


func spawn():
	if not defeated:
		spawn = int(rand_range(MIN_QUANTITY, MAX_QUANTITY))
		for idx in range(spawn):
			spawn_one()


func spawn_one():
	var point = get_next_spawn_point()
	var instance = load(SPAWN_NPC).instance()
	instance.position = point
	add_child(instance)
	instance.connect("tree_exited", self, "_on_NPC_tree_exited")


func get_next_spawn_point():
	var target_vector = Vector2(
		rand_range(-SPREAD_RADIUS, SPREAD_RADIUS),
		rand_range(-SPREAD_RADIUS, SPREAD_RADIUS)
	)
	return target_vector


func _on_NPC_tree_exited():
	if RESPAWN_ONCE_DEAD:
		call_deferred("spawn_one")
	else:
		dead += 1
		if dead == spawn:
			if DEFEATABLE:
				defeated = true
			emit_signal("defeated")


func save_data():
	return {
		pos = {
			x = global_position.x,
			y = global_position.y
		},
		defeated = defeated
	}


func load_data(data):
	defeated = data.defeated
	if defeated:
		emit_signal("defeated")


func _on_VisibilityEnabler2D_screen_entered():
	if not spawned:
		spawned = true
		call_deferred("spawn")

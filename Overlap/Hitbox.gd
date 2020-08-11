extends Area2D
class_name Hitbox

export(int) var KNOCKBACK_FACTOR = 100
export(bool) var ENABLE_KNOCKBACK = false
export(int) var DAMAGE = 1

var knockback_vector = Vector2.ZERO

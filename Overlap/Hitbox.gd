extends Area2D
class_name Hitbox

export(int) var KNOCKBACK_FACTOR = 100
export(bool) var ENABLE_KNOCKBACK = false
export(int) var DAMAGE = 1

# If true, enemy is re-damaged by staying
# inside the collision shape (no need to exit and re-enter)
export(bool) var PERSIST_DAMAGE = false

# Float b/w 0 and 1 used as a percent to reduce
# movement by. 1 means do nothing, 0.5 would
# cut movement speed in half while 0 would prevent
# movement
export(float) var MOVEMENT_BUF = 1

# Direction to apply knockback force
var knockback_vector = Vector2.ZERO

extends Potion

export(int) var RESTORE_HEALTH_POINTS = 2


func collect():
	var data = .collect()
	data["restore_health_points"] = RESTORE_HEALTH_POINTS
	return data

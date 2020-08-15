extends InteractibleObject

export(String) var message = ""


func interact():
	if len(message) > 0:
		Utils.say_dialog(message)

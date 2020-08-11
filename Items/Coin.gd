extends CollectibleItem


func collect():
	print("Collect a coin")
	PlayerStats.money += 1

extends CollectibleItem
class_name Coin

export(int) var VALUE = 1


func collect():
	var data = .collect()
	data["value"] = VALUE
	return data

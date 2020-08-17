extends Node

const CoinScene = preload("res://Items/Coin.tscn")
const DoorKeyScene = preload("res://Items/DoorKey.tscn")
const ChestKeyScene = preload("res://Items/ChestKey.tscn")
const FirePotionScene = preload("res://Items/FirePotion.tscn")
const IcePotionScene = preload("res://Items/IcePotion.tscn")
const HealthPotionScene = preload("res://Items/HealthPotion.tscn")
const FireAmuletScene = preload("res://Items/FireAmulet.tscn")
const WaterAmuletScene = preload("res://Items/WaterAmulet.tscn")
const AirAmuletScene = preload("res://Items/AirAmulet.tscn")
const EartchAmuletScene = preload("res://Items/EarthAmulet.tscn")


var items = [
	CoinScene,          # ID == 0
	DoorKeyScene,       # ID == 1
	ChestKeyScene,      # ID == 2
	FirePotionScene,    # ID == 3
	IcePotionScene,     # ID == 4
	HealthPotionScene,  # ID == 5
	FireAmuletScene,    # ID == 6
	WaterAmuletScene,   # ID == 7
	AirAmuletScene,     # ID == 8
	EartchAmuletScene,  # ID == 9
]

var item_name_map = {}


func _ready():
	item_name_map["Coin"] = 0
	item_name_map["DoorKey"] = 1
	item_name_map["ChestKey"] = 2
	item_name_map["FirePotion"] = 3
	item_name_map["IcePotion"] = 4
	item_name_map["HealthPotion"] = 5
	item_name_map["FireAmulet"] = 6
	item_name_map["WaterAmulet"] = 7
	item_name_map["AirAmulet"] = 8
	item_name_map["EarthAmulet"] = 9


func instance_item_on_main(item_id, position=Vector2.ZERO):
	return Utils.instance_scene_on_main(items[item_id], position)


func get_item_packed_scene(item_id):
	return items[item_id]


func get_item_id(item_name):
	return item_name_map[item_name]

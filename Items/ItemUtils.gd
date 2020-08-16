extends Node

const CoinScene = preload("res://Items/Coin.tscn")
const DoorKeyScene = preload("res://Items/DoorKey.tscn")
const ChestKeyScene = preload("res://Items/ChestKey.tscn")
const FirePotionScene = preload("res://Items/FirePotion.tscn")
const IcePotionScene = preload("res://Items/IcePotion.tscn")
const HealthPotionScene = preload("res://Items/HealthPotion.tscn")

var items = [
	CoinScene,          # ID == 0
	DoorKeyScene,       # ID == 1
	ChestKeyScene,      # ID == 2
	FirePotionScene,    # ID == 3
	IcePotionScene,     # ID == 4
	HealthPotionScene,  # ID == 5
]

var item_name_map = {}


func _ready():
	item_name_map["Coin"] = 0
	item_name_map["DoorKey"] = 1
	item_name_map["ChestKey"] = 2
	item_name_map["FirePotion"] = 3
	item_name_map["IcePotion"] = 4
	item_name_map["HealthPotion"] = 5


func instance_item_on_main(item_id, position=Vector2.ZERO):
	return Utils.instance_scene_on_main(items[item_id], position)


func get_item_packed_scene(item_id):
	return items[item_id]


func get_item_id(item_name):
	return item_name_map[item_name]

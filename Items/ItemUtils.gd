extends Node

const CoinScene = preload("res://Items/Coin.tscn")
const KeyScene = preload("res://Items/Key.tscn")
const FirePotionScene = preload("res://Items/FirePotion.tscn")
const IcePotionScene = preload("res://Items/IcePotion.tscn")

var items = [
	CoinScene,        # ID == 0
	KeyScene,         # ID == 1
	FirePotionScene,  # ID == 2
	IcePotionScene,   # ID == 3
]

var item_name_map = {}


func _ready():
	item_name_map["Coin"] = 0
	item_name_map["Key"] = 1
	item_name_map["FirePotion"] = 2
	item_name_map["IcePotion"] = 3


func instance_item_on_main(item_id, position=Vector2.ZERO):
	return Utils.instance_scene_on_main(items[item_id], position)


func get_item_packed_scene(item_id):
	return items[item_id]


func get_item_id(item_name):
	return item_name_map[item_name]

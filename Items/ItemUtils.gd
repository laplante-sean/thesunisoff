extends Node

const Coin = preload("res://Items/Coin.tscn")
const Key = preload("res://Items/Key.tscn")

var items = [
	Coin,  # ID == 0
	Key,   # ID == 1
]


var item_name_map = {
	Coin = 0,
	Key = 1
}


func instance_item_on_main(item_id, position=Vector2.ZERO):
	return Utils.instance_scene_on_main(items[item_id], position)


func get_item_packed_scene(item_id):
	return items[item_id]


func get_item_id(item_name):
	return item_name_map[item_name]

extends Node

const Coin = preload("res://Items/Coin.tscn")
const Key = preload("res://Items/Key.tscn")

var items = [
	Coin,  # ID == 0
	Key,   # ID == 1
]


func instance_item_on_main(item_id, position=Vector2.ZERO):
	return Utils.instance_scene_on_main(items[item_id], position)

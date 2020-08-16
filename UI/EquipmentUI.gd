extends Control


onready var healthPotion = $HealthPotion
onready var firePotion = $FirePotion
onready var icePotion = $IcePotion
onready var itemBar = $ItemBar


var type = Player.EquipedPotion.NONE setget set_type


func _ready():
	Events.connect("equip_potion", self, "_on_Events_equip_potion")


func _process(delta):
	match self.type:
		Player.EquipedPotion.NONE:
			itemBar.visible = false
		Player.EquipedPotion.HEALTH:
			itemBar.visible = true
			itemBar.rect_scale.x = clamp(PlayerStats.count_item(ItemUtils.get_item_id("HealthPotion")), 0, 8)
		Player.EquipedPotion.FIRE:
			itemBar.visible = true
			itemBar.rect_scale.x = clamp(PlayerStats.count_item(ItemUtils.get_item_id("FirePotion")), 0, 8)
		Player.EquipedPotion.ICE:
			itemBar.visible = true
			itemBar.rect_scale.x = clamp(PlayerStats.count_item(ItemUtils.get_item_id("IcePotion")), 0, 8)


func set_type(value):
	type = value
	
	match type:
		Player.EquipedPotion.NONE:
			visible = false
		Player.EquipedPotion.HEALTH:
			visible = true
			healthPotion.visible = true
			firePotion.visible = false
			icePotion.visible = false
		Player.EquipedPotion.FIRE:
			visible = true
			healthPotion.visible = false
			firePotion.visible = true
			icePotion.visible = false
		Player.EquipedPotion.ICE:
			visible = true
			healthPotion.visible = false
			firePotion.visible = false
			icePotion.visible = true


func _on_Events_equip_potion(value):
	self.type = value

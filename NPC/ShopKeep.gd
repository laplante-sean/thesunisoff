extends NPC

export(int) var HEALTH_PRICE = 50
export(int) var FIRE_PRICE = 100
export(int) var ICE_PRICE = 200


var purchase_confirmation = null
var purchase_price = 0
var purchase_item = DialogBox.ShopItem.NONE


func _ready():
	Events.connect("purchase_item", self, "_on_Events_purchase_item")
	Events.connect("yesno_answer", self, "_on_Events_yesno_answer")


func _physics_process(delta):
	match state:
		NPCState.IDLE:
			sprite.animation = "Idle"
		NPCState.WANDER:
			sprite.animation = "Walk"


func interact():
	if PlayerStats.has_all_four_amulets() and len(ALL_THE_AMULETS_MESSAGE) > 0:
		Utils.say_dialog(ALL_THE_AMULETS_MESSAGE)
		return

	Utils.shop_dialog("What're you buyin'?")

	emit_signal("interacted_with")


func _on_Events_purchase_item(item):
	purchase_item = item
	
	match item:
		DialogBox.ShopItem.HEALTH:
			purchase_confirmation = "Purchase a health potion for {coins} coins?".format({"coins": HEALTH_PRICE})
			purchase_price = HEALTH_PRICE
		DialogBox.ShopItem.FIRE:
			purchase_confirmation = "Purchase a fire potion for {coins} coins?".format({"coins": FIRE_PRICE})
			purchase_price = FIRE_PRICE
		DialogBox.ShopItem.ICE:
			purchase_confirmation = "Purchase an ice potion for {coins} coins?".format({"coins": ICE_PRICE})
			purchase_price = ICE_PRICE
		DialogBox.ShopItem.NONE:
			purchase_price = 0
			return

	Utils.call_deferred("ask_dialog", purchase_confirmation)


func _on_Events_yesno_answer(question, answer):
	if purchase_confirmation == null or purchase_price == 0 or purchase_item == DialogBox.ShopItem.NONE:
		return
	
	if purchase_confirmation == question and answer:
		if PlayerStats.money >= purchase_price:
			match purchase_item:
				DialogBox.ShopItem.HEALTH:
					ItemUtils.instance_item_on_main(ItemUtils.get_item_id("HealthPotion"), global_position)
				DialogBox.ShopItem.FIRE:
					ItemUtils.instance_item_on_main(ItemUtils.get_item_id("FirePotion"), global_position)
				DialogBox.ShopItem.ICE:
					ItemUtils.instance_item_on_main(ItemUtils.get_item_id("IcePotion"), global_position)
			
			PlayerStats.money -= purchase_price
			Utils.call_deferred("say_dialog", "hehehe. Thank you.")
		else:
			Utils.call_deferred("say_dialog", "Not enough cash! Stranger.")

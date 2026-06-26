class_name UI_GameOver_Store
extends Control

@onready var STORE_PRODUCT_SCN := preload("res://ui/game_over/store/store_product.tscn")

signal on_purchase(product: String, price: int)


func on_reroll() -> void:
	_on_reroll()


func _ready() -> void:
	# for debug
	if get_tree().current_scene == self:
		CurrentRunState.inventory_handler.hold_item("ketchup.tres")
		CurrentRunState.score_handler.settle(100)
	_on_reroll()


func _on_reroll() -> void:
	var all_keys := CurrentRunState_Inventory.get_purchasable_items()
	var all_affordables := (
			all_keys.filter(CurrentRunState_Inventory.is_item_affordable) as Array[String]
	)
	var all_rest := all_keys.filter(CurrentRunState_Inventory.is_item_unaffordable) as Array[String]
	var pick: Array[String] = []

	var affordables_count := 0
	for index in range(0, 3):
		print(all_affordables)
		var affordable: Variant = all_affordables.pop_back()
		if affordable != null && affordables_count < 2:
			affordables_count += 1
			pick.push_back(affordable)
		else:
			pick.push_back(all_rest.pop_back())

	pick.shuffle()

	for child in %StoreRoot.get_children():
		%StoreRoot.remove_child(child)
	for unlockable in pick:
		var unlockable_cp := CurrentRunState.inventory_handler.get_next_item(unlockable)
		if unlockable_cp == null:
			unlockable_cp = load("res://data/unlockables/ketchup.tres")
		var store_product_scn: UI_GameOver_StoreProduct = STORE_PRODUCT_SCN.instantiate()
		store_product_scn.product = unlockable_cp
		store_product_scn.on_purchase_pressed.connect(
			func() -> void: on_purchase.emit(unlockable, unlockable_cp.price)
		)

		%StoreRoot.add_child(store_product_scn)

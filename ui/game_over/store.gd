class_name UI_GameOver_Store
extends Control

@onready var STORE_PRODUCT_SCN := preload("res://ui/game_over/store/store_product.tscn")
@onready var stock := ResourceLoader.list_directory("res://data/unlockables")

signal on_purchase(product: String, price: int)


func on_reroll() -> void:
	_on_reroll()


func _ready() -> void:
	_on_reroll()


func _on_reroll() -> void:
	var all_keys := get_purchasable_items()
	all_keys.shuffle()
	var pick := all_keys.slice(0, 3) as Array[String]

	for child in %StoreRoot.get_children():
		%StoreRoot.remove_child(child)
	for unlockable in pick:
		var unlockable_cp := get_item(unlockable)
		var store_product_scn: UI_GameOver_StoreProduct = STORE_PRODUCT_SCN.instantiate()
		store_product_scn.product = unlockable_cp
		store_product_scn.on_purchase_pressed.connect(
			func() -> void:
				on_purchase.emit(unlockable, unlockable_cp.price)
		)

		%StoreRoot.add_child(store_product_scn)


func get_item_raw(file_name: String) -> UnlockableResource:
	return load("res://data/unlockables/" + file_name)


func get_item(key: String) -> UnlockableResource:
	var resource := get_item_raw(key)
	if resource == null:
		printerr("oopsie")
		resource = load("res://data/unlockables/ketchup.tres")

	if !resource.is_incremental:
		return resource

	var inc_res := resource.duplicate(false) as UnlockableResource
	var tier := CurrentRunState.inventory_handler.get_held_item_tier(key) + 1
	inc_res.price = int(float(inc_res.price) * inc_res.incremental_mult * float(tier))
	inc_res.incremental_value = inc_res.incremental_value * inc_res.incremental_mult * tier
	inc_res._tier = tier

	var value_str := "%.1f" % inc_res.incremental_value
	if value_str.ends_with(".0"):
		value_str = "%.0f" % inc_res.incremental_value
	inc_res.desc = inc_res.desc.format([value_str])

	if inc_res.incremental_extra_names.size() >= tier:
		inc_res.name = inc_res.incremental_extra_names[tier - 1]
	return inc_res


func get_purchasable_items() -> Array[String]:
	var keys: Array[String] = []
	for key in stock:
		if get_item_raw(key).is_incremental == true:
			keys.push_back(key)
		elif !CurrentRunState.inventory_handler.is_holding_item(key):
			keys.push_back(key)
	return keys

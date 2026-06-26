class_name CurrentRunState_Inventory
extends Node

var _held_items: Dictionary[String, int] = {}

signal item_got_held(item: String)


func hold_item(item: String) -> void:
	if not _held_items.has(item):
		_held_items[item] = 1
	else:
		_held_items[item] += 1
	item_got_held.emit(item)


func is_holding_item(item: StringName) -> bool:
	return _held_items.has(item)


func get_held_item_tier(item: String) -> int:
	return _held_items.get(item, 0)


func get_item_at_tier(key: String, tier: int) -> UnlockableResource:
	var resource := get_item_raw(key)
	if resource == null:
		printerr("oopsie")
		return null

	if !resource.is_incremental:
		return resource

	var inc_res := resource.duplicate(false) as UnlockableResource
	inc_res.price = int(float(inc_res.price) * inc_res.incremental_mult * float(tier))
	inc_res.incremental_value = inc_res.incremental_value * inc_res.incremental_mult * tier

	if inc_res.incremental_modulo_at > 0:
		print(tier, "-", inc_res.incremental_modulo_at, "-", tier % inc_res.incremental_modulo_at)
		tier = tier % inc_res.incremental_modulo_at

	inc_res._tier = tier

	var value_str := "%.1f" % inc_res.incremental_value
	if value_str.ends_with(".0"):
		value_str = "%.0f" % inc_res.incremental_value
	inc_res.desc = inc_res.desc.format([value_str])

	if inc_res.incremental_extra_names.size() > tier:
		inc_res.name = inc_res.incremental_extra_names[tier]

	if inc_res.incremental_extra_icons.size() > tier:
		inc_res.icon = inc_res.incremental_extra_icons[tier]

	return inc_res


func get_next_item(key: String) -> UnlockableResource:
	var tier := get_held_item_tier(key)
	return get_item_at_tier(key, tier + 1)


func get_item(key: String) -> UnlockableResource:
	var tier := get_held_item_tier(key)
	return get_item_at_tier(key, tier)


static func get_item_raw(file_name: String) -> UnlockableResource:
	return load("res://data/unlockables/" + file_name)


static func get_all_items() -> PackedStringArray:
	return ResourceLoader.list_directory("res://data/unlockables")


static func get_purchasable_items() -> Array[String]:
	var keys: Array[String] = []
	var all_keys: Array[String] = Array(Array(get_all_items()), TYPE_STRING, "", null)
	all_keys = all_keys.filter(
		func(item: String) -> bool:
			var raw := get_item_raw(item)
			if raw.requires.size() == 0:
				return true
			for requisite in raw.requires:
				if !CurrentRunState.inventory_handler.is_holding_item(requisite):
					return false
			return true
	)
	for key in all_keys:
		if get_item_raw(key).is_incremental == true:
			keys.push_back(key)
		elif !CurrentRunState.inventory_handler.is_holding_item(key):
			keys.push_back(key)
	keys.shuffle()
	return keys


static func get_affordable_items() -> Array[String]:
	return get_purchasable_items().filter(is_item_affordable)


static func is_item_affordable(item: String) -> bool:
	var item_resource := CurrentRunState.inventory_handler.get_next_item(item)
	return is_affordable(item_resource)


static func is_item_unaffordable(item: String) -> bool:
	return !is_item_affordable(item)


static func is_affordable(item: UnlockableResource) -> bool:
	var money_held := CurrentRunState.score_handler.current_session_score
	return max(0, money_held) >= item.price


static func is_unaffordable(item: UnlockableResource) -> bool:
	return !is_affordable(item)

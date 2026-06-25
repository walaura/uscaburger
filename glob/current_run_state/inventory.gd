class_name CurrentRunState_Inventory
extends Node

var _held_items: Dictionary[String, int] = {}

signal item_got_held(item: String)


func hold_item(item: String) -> void:
	item_got_held.emit(item)
	if not _held_items.has(item):
		_held_items[item] = 1
	else:
		_held_items[item] += 1


func is_holding_item(item: StringName) -> bool:
	return _held_items.has(item)


func get_held_item_tier(item: String) -> int:
	return _held_items.get(item, 0)


func get_item(key: String) -> UnlockableResource:
	var resource := Helper.get_item_raw(key)
	if resource == null:
		printerr("oopsie")
		return null

	if !resource.is_incremental:
		return resource

	var inc_res := resource.duplicate(false) as UnlockableResource
	var tier := get_held_item_tier(key) + 1
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

class_name CurrentRunState_Inventory
extends Node

var _held_items: Dictionary[String, int] = { }

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

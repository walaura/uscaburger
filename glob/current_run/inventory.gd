class_name CurrentRun_Inventory
extends RefCounted

var _held_items: Dictionary[String, int] = {}

signal item_got_held(item: RsUnlockableWTier)


func hold_item(item: RsUnlockableWTier) -> void:
	_held_items[item.get_key()] = item.tier
	print(item, item.tier)
	print(_held_items)
	item_got_held.emit(item)


func get_held_item_by_key(key: String) -> RsUnlockableWTier:
	if not _held_items.has(key):
		return null
	return get_item_at_held_tier(_get_item_raw(key))


func is_holding_item(resource: RsUnlockableBase) -> bool:
	return is_holding_key(resource.get_key())


func is_holding_key(key: String) -> bool:
	return _held_items.has(key)


func get_all_held_items_as_uniques() -> Array[RsUnlockableWTier]:
	# list all held items but when they got tiers, show 1 item per tier instead of collapsing them
	var uniques: Array[RsUnlockableWTier] = []
	print(_held_items)
	for key in _held_items:
		var count := _held_items[key]
		var resource := _get_item_raw(key)
		for i in range(count):
			uniques.append(resource.apply_tier(i + 1))
	return uniques


func get_all_possible_holdable_items_as_uniques() -> Array[RsUnlockableWTier]:
	var all_items: Array[RsUnlockableWTier] = []
	for key in _get_all_items():
		var resource := _get_item_raw(key)
		var max_tier := resource.get_max_tier()
		for i in range(max_tier):
			all_items.append(resource.apply_tier(i + 1))
	return all_items


func get_item_at_purchasable_tier(resource: RsUnlockable) -> RsUnlockableWTier:
	var tier := _get_held_item_tier(resource)
	return resource.apply_tier(tier + 1)


func get_item_at_held_tier(resource: RsUnlockable) -> RsUnlockableWTier:
	var tier := _get_held_item_tier(resource)
	return resource.apply_tier(tier)


func get_purchasable_items() -> Array[RsUnlockableWTier]:
	var purchasable_items: Array[RsUnlockableWTier] = []
	var all_items: Array[RsUnlockableWTier] = []

	for key in _get_all_items():
		all_items.append(get_item_at_purchasable_tier(_get_item_raw(key)))

	all_items = all_items.filter(
		func(item: RsUnlockableWTier) -> bool:
			if item.og.requires.size() == 0:
				return true
			for requisite in item.og.requires:
				if !CurrentRun.inventory.is_holding_key(requisite):
					return false
			return true
	)

	for item in all_items:
		if item.og.is_incremental == true:
			purchasable_items.push_back(item)
		elif !CurrentRun.inventory.is_holding_item(item):
			purchasable_items.push_back(item)
	purchasable_items.shuffle()

	return purchasable_items


func is_affordable(item: RsUnlockableWTier) -> bool:
	var money_held := CurrentRun.score.current_session_score
	return max(0, money_held) >= item.price


func is_unaffordable(item: RsUnlockableWTier) -> bool:
	return !is_affordable(item)


func is_incremental(item: RsUnlockableWTier) -> bool:
	return item.og.is_incremental


func is_nonincremental(item: RsUnlockableWTier) -> bool:
	return !is_incremental(item)


static func _get_item_raw(file_name: String) -> RsUnlockable:
	return load("res://data/unlockables/" + file_name)


static func _get_all_items() -> PackedStringArray:
	return ResourceLoader.list_directory("res://data/unlockables")


func _get_held_item_tier(resource: RsUnlockableBase) -> int:
	return _get_held_item_by_key_tier(resource.get_key())


func _get_held_item_by_key_tier(key: String) -> int:
	return _held_items.get(key, 0)

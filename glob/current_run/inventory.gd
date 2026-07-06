class_name CurrentRun_Inventory
extends RefCounted

var ALL_RAW_ITEMS: Dictionary[String, RsRawItem] = {}

var _held_items: Dictionary[String, int] = {}

signal item_got_held(item: RsItem)


func hold_item(item: RsItem) -> void:
	_held_items[item.get_key()] = item.tier
	item_got_held.emit(item)


func get_held_item_by_key(key: String) -> RsItem:
	if not _held_items.has(key):
		return null
	return get_item_at_held_tier(_get_item_raw(key))


func is_holding_item(resource: RsBaseItem) -> bool:
	return is_holding_key(resource.get_key())


func is_holding_key(key: String) -> bool:
	return _held_items.has(key)


func get_all_held_items_as_uniques() -> Array[RsItem]:
	# list all held items but when they got tiers, show 1 item per tier instead of collapsing them
	var uniques: Array[RsItem] = []
	for key in _held_items:
		var count := _held_items[key]
		var resource := _get_item_raw(key)
		for i in range(count):
			uniques.append(resource.apply_tier(i + 1))
	return uniques


func get_all_possible_holdable_items_as_uniques() -> Array[RsItem]:
	var all_items: Array[RsItem] = []
	for key in _get_all_items():
		var resource := _get_item_raw(key)
		var max_tier := resource.get_max_tier()
		for i in range(max_tier):
			all_items.append(resource.apply_tier(i + 1))
	return all_items


func get_item_at_purchasable_tier(resource: RsRawItem) -> RsItem:
	var tier := _get_held_item_tier(resource)
	return resource.apply_tier(tier + 1)


func get_item_at_held_tier(resource: RsRawItem) -> RsItem:
	var tier := _get_held_item_tier(resource)
	return resource.apply_tier(tier)


func get_purchasable_items() -> Array[RsItem]:
	var purchasable_items: Array[RsItem] = []
	var all_items: Array[RsItem] = []

	for key in _get_all_items():
		all_items.append(get_item_at_purchasable_tier(_get_item_raw(key)))

	all_items = all_items.filter(
		func(item: RsItem) -> bool:
			if item.og.requires.size() == 0:
				return true
			for requisite in item.og.requires:
				if !CurrentRun.inventory.is_holding_key(requisite):
					return false
			return true
	)

	for item in all_items:
		if item.og is RsRawItemIncremental == true:
			purchasable_items.push_back(item)
		elif !CurrentRun.inventory.is_holding_item(item):
			purchasable_items.push_back(item)
	purchasable_items.shuffle()

	return purchasable_items


func is_affordable(item: RsItem) -> bool:
	var money_held := CurrentRun.score.current_session_score
	return max(0, money_held) >= item.price


func is_unaffordable(item: RsItem) -> bool:
	return !is_affordable(item)


func is_incremental(item: RsItem) -> bool:
	return item.og is RsRawItemIncremental


func is_nonincremental(item: RsItem) -> bool:
	return !is_incremental(item)


static func _get_item_raw(file_name: String) -> RsRawItem:
	return load(_get_item_path(file_name)) as RsRawItem


static func _get_all_items() -> PackedStringArray:
	return ResourceLoader.list_directory("res://data/unlockables")


static func _get_item_path(file_name: String) -> String:
	return "res://data/unlockables/" + file_name


func _get_held_item_tier(resource: RsBaseItem) -> int:
	return _get_held_item_by_key_tier(resource.get_key())


func _get_held_item_by_key_tier(key: String) -> int:
	return _held_items.get(key, 0)

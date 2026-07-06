class_name SavedRecordsResource
extends SerializableResource

var tot: SavedRecordIntResource
var max_money: SavedRecordIntResource
var max_parts: SavedRecordIntResource
var max_height: SavedRecordFloatResource

var seen_badges: Array[SavedRecordStrResource]
var purchased_badges: Array[SavedRecordStrResource]


func has_seen_badge(resource: RsItem) -> bool:
	var name := resource.get_key_w_tier()
	if name != null and seen_badges.find_custom(func(sr: SavedRecordStrResource) -> bool: return sr.record == name) != -1:
		return true
	return false


func has_purchased_badge(resource: RsItem) -> bool:
	var name := resource.get_key_w_tier()
	if name != null and purchased_badges.find_custom(func(sr: SavedRecordStrResource) -> bool: return sr.record == name) != -1:
		return true
	return false


func maybe_mark_badge_as_seen(resource: RsItem) -> bool:
	var name := resource.get_key_w_tier()
	if !has_seen_badge(resource):
		seen_badges.push_back(SavedRecordStrResource.new(name))
		return true
	return false


func maybe_mark_badge_as_purchased(resource: RsItem) -> bool:
	var name := resource.get_key_w_tier()
	if !has_purchased_badge(resource):
		purchased_badges.push_back(SavedRecordStrResource.new(name))
		return true
	return false


func maybe_update_max_money(value: int) -> bool:
	if max_money == null:
		max_money = SavedRecordIntResource.new(value)
		return true
	if max_money.record < value:
		max_money.record = value
		return true
	return false


func maybe_update_max_parts(value: int) -> bool:
	if max_parts == null:
		max_parts = SavedRecordIntResource.new(value)
		return true
	if max_parts.record < value:
		max_parts.record = value
		return true
	return false


func maybe_update_max_height(value: float) -> bool:
	if max_height == null:
		max_height = SavedRecordFloatResource.new(value)
		return true
	if max_height.record < value:
		max_height.record = value
		return true
	return false


func maybe_update_tot(value: int) -> bool:
	if tot == null:
		tot = SavedRecordIntResource.new(value)
		return true
	tot.record += value
	return true


func serialize() -> Dictionary:
	var rt: Dictionary = {}
	if max_money != null:
		rt["max_money"] = max_money.serialize()
	if max_parts != null:
		rt["max_parts"] = max_parts.serialize()
	if max_height != null:
		rt["max_height"] = max_height.serialize()
	if tot != null:
		rt["tot"] = tot.serialize()

	if seen_badges.size() > 0:
		var rta := []
		for badge in seen_badges:
			rta.append(badge.serialize())
		rt["seen_badges"] = rta

	if purchased_badges.size() > 0:
		var rta := []
		for badge in purchased_badges:
			rta.append(badge.serialize())
		rt["purchased_badges"] = rta
	return rt


static func deserialize(data: Dictionary) -> SavedRecordsResource:
	var res := SavedRecordsResource.new()

	if data.has("tot") and data["tot"] is Dictionary:
		@warning_ignore("UNSAFE_CAST")
		res.tot = SavedRecordIntResource.deserialize(data["tot"] as Dictionary)
	if data.has("max_money") and data["max_money"] is Dictionary:
		@warning_ignore("UNSAFE_CAST")
		res.max_money = SavedRecordIntResource.deserialize(data["max_money"] as Dictionary)
	if data.has("max_parts") and data["max_parts"] is Dictionary:
		@warning_ignore("UNSAFE_CAST")
		res.max_parts = SavedRecordIntResource.deserialize(data["max_parts"] as Dictionary)
	if data.has("max_height") and data["max_height"] is Dictionary:
		@warning_ignore("UNSAFE_CAST")
		res.max_height = SavedRecordFloatResource.deserialize(data["max_height"] as Dictionary)

	if data.has("seen_badges") and data["seen_badges"] is Array:
		var rta: Array = data["seen_badges"]
		if rta is not Array:
			return
		for badge: Variant in rta:
			if badge is Dictionary:
				@warning_ignore("UNSAFE_CAST")
				res.seen_badges.append(SavedRecordStrResource.deserialize(badge as Dictionary))
	if data.has("purchased_badges") and data["purchased_badges"] is Array:
		var rta: Array = data["purchased_badges"]
		if rta is not Array:
			return
		for badge: Variant in rta:
			if badge is Dictionary:
				@warning_ignore("UNSAFE_CAST")
				res.purchased_badges.append(SavedRecordStrResource.deserialize(badge as Dictionary))
	return res

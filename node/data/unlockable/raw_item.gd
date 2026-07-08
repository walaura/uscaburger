class_name RsRawItem
extends RsBaseItem

## wont show up without these
@export var requires: Array[StringName]
@export var require_condition_script: ItemUnlockCondition


func get_max_tier() -> int:
	var incr := self as RsRawItemIncremental
	if incr == null:
		return 1
	var incr_mod := self as RsRawItemIncrementalModulo
	if incr_mod != null:
		return incr_mod.incremental_modulo_at
	return maxi(incr.incremental_extra_icons.size(), maxi(incr.incremental_extra_names.size(), 1))


func apply_tier(tier: int) -> RsItem:
	var new_resource := RsItem.new()
	new_resource.name = name
	new_resource.icon = icon
	new_resource.desc = desc
	new_resource.fx_short_desc = fx_short_desc
	new_resource.price = price
	new_resource.og = self

	var incr := self as RsRawItemIncremental
	if !incr:
		return new_resource

	new_resource.price = (new_resource.price + int(float(new_resource.price) * (incr.incremental_mult * 2) * float(tier - 1)))
	new_resource.incremental_value = incr.incremental_value * incr.incremental_mult * tier

	var incr_mod := incr as RsRawItemIncrementalModulo
	if incr_mod && incr_mod.incremental_modulo_at > 0:
		tier = tier % incr_mod.incremental_modulo_at

	new_resource.tier = tier

	var value_str := "%.1f" % new_resource.incremental_value
	if value_str.ends_with(".0"):
		value_str = "%.0f" % new_resource.incremental_value
	new_resource.desc = new_resource.desc.format([value_str])
	new_resource.fx_short_desc = new_resource.fx_short_desc.format([value_str])

	if incr.incremental_extra_names.size() > tier:
		new_resource.name = incr.incremental_extra_names[tier]

	if incr.incremental_extra_icons.size() > tier:
		new_resource.icon = incr.incremental_extra_icons[tier]

	return new_resource

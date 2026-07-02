@tool
class_name RsUnlockable
extends RsUnlockableBase

## wont show up without these
@export var requires: Array[StringName]

@export_group("Incremental stuffs")
@export var is_incremental: bool
@export var incremental_mult: float
@export var incremental_extra_names: Array[String]
@export var incremental_extra_icons: Array[CompressedTexture2D]
@export var incremental_modulo_at: int = -1

@warning_ignore_start("unused_private_class_variable")
@export_group("Secret sys stuff")
@export_range(1, 1, 1) var _tier: int = 1


func get_max_tier() -> int:
	return maxi(incremental_extra_icons.size(), maxi(incremental_extra_names.size(), 1))


func apply_tier(tier: int) -> RsUnlockableWTier:
	var new_resource := RsUnlockableWTier.new()
	new_resource.name = name
	new_resource.icon = icon
	new_resource.desc = desc
	new_resource.fx_short_desc = fx_short_desc
	new_resource.price = price
	new_resource.og = self

	if !is_incremental:
		return new_resource

	new_resource.price = (new_resource.price + int(float(new_resource.price) * (incremental_mult * 2) * float(tier - 1)))
	new_resource.incremental_value = incremental_value * incremental_mult * tier

	if incremental_modulo_at > 0:
		tier = tier % incremental_modulo_at

	new_resource.tier = tier

	var value_str := "%.1f" % new_resource.incremental_value
	if value_str.ends_with(".0"):
		value_str = "%.0f" % new_resource.incremental_value
	new_resource.desc = new_resource.desc.format([value_str])
	new_resource.fx_short_desc = new_resource.fx_short_desc.format([value_str])

	if incremental_extra_names.size() > tier:
		new_resource.name = incremental_extra_names[tier]

	if incremental_extra_icons.size() > tier:
		new_resource.icon = incremental_extra_icons[tier]

	return new_resource

@tool
class_name RsUnlockable
extends Resource

@export_multiline var name: String
@export var icon: CompressedTexture2D
@export_multiline var desc: String
## Shows in the run totals as the multplier
@export_multiline var fx_short_desc: String
@export var price: int

## wont show up without these
@export var requires: Array[StringName]

@export_group("Incremental stuffs")
@export var is_incremental: bool
@export var incremental_mult: float
@export var incremental_value: float
@export var incremental_extra_names: Array[String]
@export var incremental_extra_icons: Array[CompressedTexture2D]
@export var incremental_modulo_at: int = -1

@warning_ignore_start("unused_private_class_variable")
@export_group("Secret sys stuff")
@export_range(1, 1, 1) var _tier: int = 1


func get_key() -> String:
	return resource_path.get_file()


func apply_tier(tier: int) -> RsUnlockable:
	if !is_incremental:
		return self

	var inc_res := self.duplicate(false) as RsUnlockable
	inc_res.price = (inc_res.price + int(float(inc_res.price) * (inc_res.incremental_mult * 2) * float(tier - 1)))
	inc_res.incremental_value = inc_res.incremental_value * inc_res.incremental_mult * tier

	if inc_res.incremental_modulo_at > 0:
		tier = tier % inc_res.incremental_modulo_at

	inc_res._tier = tier

	var value_str := "%.1f" % inc_res.incremental_value
	if value_str.ends_with(".0"):
		value_str = "%.0f" % inc_res.incremental_value
	inc_res.desc = inc_res.desc.format([value_str])
	inc_res.fx_short_desc = inc_res.fx_short_desc.format([value_str])

	if inc_res.incremental_extra_names.size() > tier:
		inc_res.name = inc_res.incremental_extra_names[tier]

	if inc_res.incremental_extra_icons.size() > tier:
		inc_res.icon = inc_res.incremental_extra_icons[tier]

	return inc_res

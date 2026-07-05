class_name RsItem
extends RsBaseItem

@export var og: RsRawItem
@export var tier: int = 1


func get_key() -> String:
	return og.resource_path.get_file()


func get_key_w_tier() -> String:
	return og.resource_path.get_file() + "/" + str(tier)


func get_tier_for_display() -> int:
	if og is RsRawItemIncrementalModulo:
		return 0
	else:
		return tier

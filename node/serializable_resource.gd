class_name SerializableResource
extends Resource


func serialize() -> String:
	var vl := JSON.stringify(_maybe_prep_for_serialize(self))
	deserialize(self, vl)
	return ""


static func deserialize(empty: SerializableResource, value: String) -> SerializableResource:
	var raw: Variant = JSON.parse_string(value)
	if raw == null:
		return null

	return _maybe_prep_for_deserialize(empty, raw)


static func _maybe_prep_for_deserialize(empty: SerializableResource, raw: Variant) -> SerializableResource:
	if raw is not Dictionary:
		return empty
	var dict: Dictionary = raw

	for empty_prop in empty.get_property_list():
		if !dict.has(empty_prop.name):
			continue
		if dict[empty_prop.name] is not Dictionary:
			empty.set(empty_prop.name, dict[empty_prop.name])
			continue
		var dict_val: Dictionary = dict[empty_prop.name]
		if not (dict_val.has("_type")):
			continue

		if dict_val._type == "serializable" and empty[empty_prop.name] is SerializableResource:
			empty.set(empty_prop.name, SerializableResource._maybe_prep_for_deserialize(empty[empty_prop.name], dict_val.value))
		if dict_val._type == "array" and empty[empty_prop.name] is Array:
			var arr: Array = empty[empty_prop.name]
			var rt := []
			for item: Variant in arr:
				rt.append(_maybe_prep_for_deserialize(item))
			empty.set(empty_prop.name, SerializableResource._maybe_prep_for_deserialize(empty[empty_prop.name], dict_val.value))

	return empty


func _should_serialize(value: Variant) -> bool:
	if value is String or value is float or value is int or value is bool or value is Array or value is SerializableResource:
		return true
	return false


func _maybe_prep_for_serialize(value: Variant) -> Variant:
	if value is SerializableResource:
		var rt := {}
		for property in (value as SerializableResource).get_property_list():
			var prop_value: Variant = (value as SerializableResource).get(property.name)
			if _should_serialize(prop_value):
				rt[property.name] = {"_type": "serializable", "value": _maybe_prep_for_serialize(prop_value)}

		return rt

	if value is Array:
		var arr: Array = value
		var rt := []
		for item: Variant in arr:
			rt.append(_maybe_prep_for_serialize(item))
		return {"_type": "array", "value": rt}

	return value

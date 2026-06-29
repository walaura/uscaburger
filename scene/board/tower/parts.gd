class_name ScTower_Parts
extends Node3D

var ALL_PARTS: Array[RsPart]
var BASE_PARTS: Array[RsPart]


func _init() -> void:
	var all_part_names := get_all_items()
	print(all_part_names)
	for part_name in all_part_names:
		var part := get_item_raw(part_name)
		if part != null:
			ALL_PARTS.push_back(part)
			if not part.is_upgrade and not part.is_crown and not part.is_heel and not part.is_patty:
				BASE_PARTS.push_back(part)
				print(BASE_PARTS)


func get_all_parts(tower_state: ScTower_State) -> Array[RsPart]:
	var all_parts := BASE_PARTS.duplicate()
	if tower_state._mode == ScTower.Mode.Chicken:
		all_parts.push_back(get_item("chicken"))
	elif tower_state._mode == ScTower.Mode.Vegan:
		## they can both be vegan ig??
		all_parts.push_back(get_item("chicken") if randf() > .5 else get_item("meat"))
	else:
		all_parts.push_back(get_item("meat"))

	if tower_state.sauce_cooldown == 0:
		if CurrentRun.inventory.is_holding_item("ketchup.tres"):
			all_parts.push_back(get_item("ketchup"))
		if CurrentRun.inventory.is_holding_item("mustard.tres"):
			all_parts.push_back(get_item("mustard"))
		if CurrentRun.inventory.is_holding_item("blue_sauce.tres"):
			all_parts.push_back(get_item("baja"))

	return all_parts


func get_random_part(tower_state: ScTower_State) -> RsPart:
	if tower_state.sauce_cooldown > 0:
		tower_state.sauce_cooldown -= 1

	var part: RsPart = get_all_parts(tower_state).pick_random()
	if tower_state._mode == ScTower.Mode.Vegan:
		part = (part).duplicate() as RsPart
		if part.is_patty:
			part.name = '"' + part.name + '"'

	if part.is_sauce:
		tower_state.sauce_cooldown = 6 + tower_state.sauce_cooldown_mult
		tower_state.sauce_cooldown_mult += 2
	return part


func get_heel() -> RsPart:
	return preload("uid://ndxsohh4fu0b")


func get_crown() -> RsPart:
	return load("uid://bvbdorjg1ompd")


static func get_item_raw(file_name: String) -> RsPart:
	print(file_name)
	return load("res://data/parts/" + file_name)


static func get_item(item_name: String) -> RsPart:
	return get_item_raw(item_name + ".tres")


static func get_all_items() -> PackedStringArray:
	return ResourceLoader.list_directory("res://data/parts")

class_name ScTower_Parts
extends Node3D

var ALL_PARTS: Array[RsPart]
var BASE_PARTS: Array[RsPart]
var UPGRADE_PARTS: Array[RsPart]


func _init() -> void:
	var all_part_names := ResourceLoader.list_directory("res://data/parts")
	for part_name in all_part_names:
		var part := get_item_raw(part_name)
		if part != null:
			ALL_PARTS.push_back(part)
			print(part, part.requires_upgrade)
			if part.requires_upgrade == null and not part.is_crown and not part.is_heel and not part.is_patty:
				BASE_PARTS.push_back(part)
			if part.requires_upgrade != null:
				UPGRADE_PARTS.push_back(part)


func get_all_parts(tower_state: ScTower_State) -> Array[RsPart]:
	var all_parts := BASE_PARTS.duplicate()
	if tower_state._mode == ScTower.Mode.Chicken:
		all_parts.push_back(get_item("chicken"))
	elif tower_state._mode == ScTower.Mode.Vegan:
		## they can both be vegan ig??
		all_parts.push_back(get_item("chicken") if randf() > .5 else get_item("meat"))
	else:
		all_parts.push_back(get_item("meat"))

	for part in UPGRADE_PARTS:
		if CurrentRun.inventory.is_holding_item(part.requires_upgrade):
			all_parts.push_back(part)

	all_parts = all_parts.filter(
		func(part: RsPart) -> bool:
			if tower_state.sauce_cooldown != 0 and part.is_sauce:
				return false

			return true
	)
	return all_parts


func get_random_part(tower_state: ScTower_State) -> RsPart:
	if tower_state.sauce_cooldown > 0:
		tower_state.sauce_cooldown -= 1

	## pickles can return another pickle almost half the time
	if tower_state.previous_item == get_item("pickle").name && randf() > .6:
		return get_item("pickle")

	var part: RsPart = get_all_parts(tower_state).pick_random()
	if tower_state._mode == ScTower.Mode.Vegan:
		part = (part).duplicate() as RsPart
		if part.is_meat:
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
	return load("res://data/parts/" + file_name)


static func get_item(item_name: String) -> RsPart:
	return get_item_raw(item_name + ".tres")

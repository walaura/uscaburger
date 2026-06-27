class_name Data_Parts
extends Node3D

@onready var BASE_PARTS: Array[Node] = [
	$"Topz-onion",
	$"Topz-cheese",
	$"Topz-tomato",
	$"Topz-lettuce",
]

@onready var REG_PATTY := $"Patty-meat"
@onready var CHIKN_PATTY := $"Patty-chick"


func get_all_parts(tower_state: Scene_Tower_ScoreHandler) -> Array[Node]:
	var all_parts := BASE_PARTS.duplicate()
	if tower_state._mode == Scene_Tower.Mode.Chicken:
		all_parts.push_back(CHIKN_PATTY)
	elif tower_state._mode == Scene_Tower.Mode.Vegan:
		## they can both be vegan ig??
		all_parts.push_back(CHIKN_PATTY if randf() > .5 else REG_PATTY)
	else:
		all_parts.push_back(REG_PATTY)

	if tower_state.sauce_cooldown == 0:
		if CurrentRunState.inventory_handler.is_holding_item("ketchup.tres"):
			all_parts.push_back($"Topz-ketchup")
		if CurrentRunState.inventory_handler.is_holding_item("mustard.tres"):
			all_parts.push_back($"Topz-mustard")
		if CurrentRunState.inventory_handler.is_holding_item("blue_sauce.tres"):
			all_parts.push_back($"Topz-mustard2")

	return all_parts


func get_random_part(tower_state: Scene_Tower_ScoreHandler) -> Droppable:
	if tower_state.sauce_cooldown > 0:
		tower_state.sauce_cooldown -= 1

	var part: Node = get_all_parts(tower_state).pick_random()
	var dupe := (part).duplicate() as Droppable

	if tower_state._mode == Scene_Tower.Mode.Vegan:
		if part == CHIKN_PATTY or part == REG_PATTY:
			dupe.receipt_name = '"' + dupe.receipt_name + '"'

	if dupe.is_sauce:
		tower_state.sauce_cooldown = 6 + tower_state.sauce_cooldown_mult
		tower_state.sauce_cooldown_mult += 2
	return dupe


func get_heel() -> Droppable:
	return $"Bun-heel".duplicate()


func get_crown() -> Droppable:
	return $"Bun-crown".duplicate()

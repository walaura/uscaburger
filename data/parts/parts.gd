class_name Data_Parts
extends Node3D

@onready var BASE_PARTS: Array[Node] = [
	$"Patty-meat",
	$"Topz-onion",
	$"Topz-cheese",
	$"Topz-tomato",
	$"Topz-lettuce",
]


func get_all_parts(tower_state: Scene_Tower_ScooreHandler) -> Array[Node]:
	var all_parts := BASE_PARTS.duplicate()
	if (tower_state.sauce_cooldown == 0):
		if CurrentRunState.inventory_handler.is_holding_item('ketchup.tres'):
			all_parts.push_back($"Topz-ketchup")
		if CurrentRunState.inventory_handler.is_holding_item('mustard.tres'):
			all_parts.push_back($"Topz-mustard")
		if CurrentRunState.inventory_handler.is_holding_item('blue-sauce.tres'):
			all_parts.push_back($"Topz-mustard2")
	return all_parts


func get_random_part(tower_state: Scene_Tower_ScooreHandler) -> Droppable:
	if tower_state.sauce_cooldown > 0:
		tower_state.sauce_cooldown -= 1

	var part: Node = get_all_parts(tower_state).pick_random()
	var dupe := (part).duplicate() as Droppable

	if (dupe.is_sauce):
		tower_state.sauce_cooldown = 5 + tower_state.sauce_cooldown_mult
		tower_state.sauce_cooldown_mult += 1
	return dupe


func get_heel() -> Droppable:
	return $"Bun-heel".duplicate()


func get_crown() -> Droppable:
	return $"Bun-crown".duplicate()

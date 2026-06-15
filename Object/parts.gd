extends Node

class_name Parts

var ALL_PARTS = ["Patty-meat", "Topz-cheese", "Topz-tomato", "Topz-lettuce"]


func get_random_part() -> Droppable:
	var dupe = get_node(ALL_PARTS.pick_random()).duplicate()
	return dupe


func get_heel() -> Droppable:
	return get_node("Bun-heel").duplicate()


func get_crown() -> Droppable:
	return get_node("Bun-crown").duplicate()

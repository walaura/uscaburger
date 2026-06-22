extends Node

class_name Data_Parts

var ALL_PARTS: Array[NodePath] = ["Patty-meat", "Topz-cheese", "Topz-tomato", "Topz-lettuce"]


func get_random_part() -> Droppable:
	var part: NodePath = ALL_PARTS.pick_random()
	var dupe := get_node(part).duplicate() as Droppable
	return dupe


func get_heel() -> Droppable:
	return get_node("Bun-heel").duplicate()


func get_crown() -> Droppable:
	return get_node("Bun-crown").duplicate()

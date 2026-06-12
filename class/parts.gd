extends Node3D

const parts_scene = preload("res://Object/parts.tscn")

func get_random_part() -> RigidBody3D:
	var instance = parts_scene.instantiate();
	
	var all_parts = [
		"Bun-heel",
		"Bun-crown",
		"Patty-meat",
		"Topz-cheese"
	]
	return instance.get_node(all_parts.pick_random()).duplicate();
	
func get_heel() -> RigidBody3D:
	var instance = parts_scene.instantiate();
	return instance.get_node("Bun-heel").duplicate();

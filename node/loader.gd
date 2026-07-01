class_name Loader
extends RefCounted

var loaded_resources: Dictionary[String, PackedScene] = {}


func queue_resource(path: String) -> void:
	var err := ResourceLoader.load_threaded_request(path)
	if err:
		printerr(err)


func get_resource(path: String) -> PackedScene:
	print(loaded_resources)
	print(ResourceLoader.load_threaded_get_status(path))

	if loaded_resources.has(path):
		return loaded_resources[path]
	var resource: PackedScene = ResourceLoader.load_threaded_get(path)
	print(ResourceLoader.load_threaded_get_status(path))
	if resource != null:
		loaded_resources[path] = resource
		return resource
	else:
		printerr("did not preload: " + path)
		return load(path)


func _exit_tree() -> void:
	print("unloading stuffs")

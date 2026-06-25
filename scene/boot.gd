extends Node2D

@export_file("*.tscn") var main_scene_path: String
var did_load := false


func _ready() -> void:
	SavedData.apply_env_gfx_settings($WorldEnvironment)
	ResourceLoader.load_threaded_request(main_scene_path)


func _process(_delta: float) -> void:
	if did_load == true:
		return

	var progress := []
	var status := ResourceLoader.load_threaded_get_status(main_scene_path, progress)
	($Label as Label).text = "%f" % (progress[0] * 100)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		did_load = true
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(main_scene_path) as PackedScene)

extends Control

@export_file("*.tscn") var main_SCpath: String
var did_load := false


func _ready() -> void:
	SavedData.apply_env_gfx_settings($WorldEnvironment)
	ResourceLoader.load_threaded_request(main_SCpath)


func _process(_delta: float) -> void:
	if did_load == true:
		return

	var progress := []
	var status := ResourceLoader.load_threaded_get_status(main_SCpath, progress)
	($Label as Label).text = "%f" % (progress[0] * 100)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		did_load = true
		var res := ResourceLoader.load_threaded_get(main_SCpath) as PackedScene
		($TransitionBase as Parts_TransitionBase).swap_to(res)

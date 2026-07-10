extends Control

@export_file("*.tscn") var main_SCpath: String
var did_load := false

@onready var timer := get_tree().create_timer(3.0)


func _ready() -> void:
	SavedData.apply_env_gfx_settings($WorldEnvironment as WorldEnvironment)
	ResourceLoader.load_threaded_request(main_SCpath)


func _process(_delta: float) -> void:
	if did_load == true:
		return

	var progress := []
	var status := ResourceLoader.load_threaded_get_status(main_SCpath, progress)
	if timer.time_left <= 0.0 and status == ResourceLoader.THREAD_LOAD_LOADED:
		did_load = true
		var res := ResourceLoader.load_threaded_get(main_SCpath) as PackedScene
		($TransitionBase as Parts_TransitionBase).swap_to(res)


func _input(event: InputEvent) -> void:
	if event.is_action("UI_Skip"):
		var status := ResourceLoader.load_threaded_get_status(main_SCpath)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var res := ResourceLoader.load_threaded_get(main_SCpath) as PackedScene
			($TransitionBase as Parts_TransitionBase).swap_to(res)

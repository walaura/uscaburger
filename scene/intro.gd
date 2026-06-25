extends Control

@export_file("*.tscn") var main_scene_path: String
@export_file("*.tscn") var settings_scene_path: String
var did_load := false


func _ready() -> void:
	ResourceLoader.load_threaded_request(main_scene_path)
	ResourceLoader.load_threaded_request(settings_scene_path)


func _on_button_seets_pressed() -> void:
	var scene_resource: PackedScene = ResourceLoader.load_threaded_get(settings_scene_path)
	if scene_resource == null:
		ResourceLoader.load_threaded_request(settings_scene_path)
		_on_button_seets_pressed()
		return

	var settings_screen: UI_Settings = scene_resource.instantiate()
	($AnimationPlayer as AnimationPlayer).play("camera_to_settings", -1, 1)

	settings_screen.on_close.connect(
		func() -> void:
			($AnimationPlayer as AnimationPlayer).play("camera_to_settings", -1, -1, true)
			remove_child(settings_screen)
	)

	var tween := create_tween()
	tween.tween_callback(
		func() -> void:
			add_child(settings_screen)
	).set_delay(1.)


func _on_button_play_pressed() -> void:
	var scene_resource: PackedScene = ResourceLoader.load_threaded_get(main_scene_path)
	if scene_resource == null:
		ResourceLoader.load_threaded_request(main_scene_path)
		_on_button_play_pressed()
		return
	get_tree().change_scene_to_packed(scene_resource)

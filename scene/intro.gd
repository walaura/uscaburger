extends Control

@export_file("*.tscn") var main_scene_path: String
@export_file("*.tscn") var settings_scene_path: String
var did_load := false

@onready var _settings_screen: UI_Settings
@onready var _camera_anim := $Node/AnimationPlayer as AnimationPlayer


func _ready() -> void:
	($SignAnimation as AnimationPlayer).play("new_animation")

	ResourceLoader.load_threaded_request(main_scene_path)
	ResourceLoader.load_threaded_request(settings_scene_path)


func _on_button_seets_pressed() -> void:
	var scene_resource: PackedScene = ResourceLoader.load_threaded_get(settings_scene_path)
	if scene_resource == null:
		ResourceLoader.load_threaded_request(settings_scene_path)
		_on_button_seets_pressed()
		return

	_settings_screen = scene_resource.instantiate()

	_camera_anim.play("camera_to_settings", -1, 1)
	($Node/MainMenuWrap as Control).hide()
	_settings_screen.on_close.connect(_on_close_settings)

	var tween := create_tween()
	tween.tween_callback(func() -> void: add_child(_settings_screen)).set_delay(1.)


func _on_close_settings() -> void:
	_camera_anim.play("camera_to_settings", -1, -1, true)
	_camera_anim.animation_finished.connect(
		func(_n: StringName) -> void:
			if _camera_anim.current_animation_position == 0.0:
				($Node/MainMenuWrap as Control).show()
				($Node/MainMenuWrap as Control).find_next_valid_focus().grab_focus.call_deferred()
	)
	remove_child(_settings_screen)


func _on_button_play_pressed() -> void:
	var scene_resource: PackedScene = ResourceLoader.load_threaded_get(main_scene_path)
	if scene_resource == null:
		ResourceLoader.load_threaded_request(main_scene_path)
		_on_button_play_pressed()
		return

	var tween := create_tween()
	(
			tween
			.tween_property(
				$"Node/AnimationPlayer/Camera3D",
				"rotation:x",
				.02,
				.2,
			)
	)
	(
			tween
			.tween_property(
				$"Node/AnimationPlayer/Camera3D",
				"rotation:x",
				-1.,
				($TransitionBase as Parts_TransitionBase).length * 2,
			)
	)

	($TransitionBase as Parts_TransitionBase).swap_to(scene_resource)

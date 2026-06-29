extends Control

@export_file("*.tscn") var main_SCpath: String
@export_file("*.tscn") var settings_SCpath: String
var did_load := false

@onready var _settings_screen: UiSettings
@onready var _camera_anim := $Node/AnimationPlayer as AnimationPlayer


func _ready() -> void:
	($SignAnimation as AnimationPlayer).play("new_animation")

	ResourceLoader.load_threaded_request(main_SCpath)
	ResourceLoader.load_threaded_request(settings_SCpath)


func _on_button_seets_pressed() -> void:
	var SCresource: PackedScene = ResourceLoader.load_threaded_get(settings_SCpath)
	if SCresource == null:
		ResourceLoader.load_threaded_request(settings_SCpath)
		_on_button_seets_pressed()
		return

	_settings_screen = SCresource.instantiate()

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
	var SCresource: PackedScene = ResourceLoader.load_threaded_get(main_SCpath)
	if SCresource == null:
		ResourceLoader.load_threaded_request(main_SCpath)
		_on_button_play_pressed()
		return

	var tween := create_tween()
	(
		tween
		. tween_property(
			$"Node/AnimationPlayer/Camera3D",
			"rotation:x",
			.02,
			.2,
		)
	)
	(
		tween
		. tween_property(
			$"Node/AnimationPlayer/Camera3D",
			"rotation:x",
			-1.,
			($TransitionBase as Parts_TransitionBase).length * 2,
		)
	)

	($TransitionBase as Parts_TransitionBase).swap_to(SCresource)

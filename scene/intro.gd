extends Control

@export_file("*.tscn") var main_SCpath: String
@export_file("*.tscn") var settings_SCpath: String
var did_load := false
var _loader := Loader.new()

var _settings_screen: UiSettings
@onready var _camera_anim := $Node/AnimationPlayer as AnimationPlayer


func _ready() -> void:
	($SignAnimation as AnimationPlayer).play("new_animation")
	_loader.queue_resource(main_SCpath)
	_loader.queue_resource(settings_SCpath)
	InputHelper.force_focus(self)


func _unhandled_input(event: InputEvent) -> void:
	InputHelper.force_grab_focus_on_input(event, self)


func _on_button_seets_pressed() -> void:
	_settings_screen = _loader.get_resource(settings_SCpath).instantiate()

	_camera_anim.play("camera_to_settings", -1, 1)
	($Node/MainMenuWrap as Control).hide()
	_settings_screen.on_close.connect(_on_close_settings)

	var tween := create_tween()
	tween.tween_callback(func() -> void: add_child(_settings_screen)).set_delay(.5)


func _on_close_settings() -> void:
	_camera_anim.play("camera_to_settings", -1, -1, true)
	_camera_anim.animation_finished.connect(
		func(_n: StringName) -> void:
			if _camera_anim.current_animation_position == 0.0:
				($Node/MainMenuWrap as Control).show()
				InputHelper.force_focus($Node/MainMenuWrap as Control)
	)
	remove_child(_settings_screen)


func _on_button_play_pressed() -> void:
	var scene := _loader.get_resource(main_SCpath)
	var tween := create_tween()
	tween.tween_property($"Node/AnimationPlayer/Camera3D", "rotation:x", .02, .2)
	tween.tween_property($"Node/AnimationPlayer/Camera3D", "rotation:x", -1., ($TransitionBase as Parts_TransitionBase).length * 2)

	($TransitionBase as Parts_TransitionBase).swap_to(scene)

extends Control

@onready var settings_SCpath := (%Settings as InstancePlaceholder).get_instance_path()
@onready var collection_SCpath := (%Collection as InstancePlaceholder).get_instance_path()

var did_load := false

@onready var _camera_anim := $Node/AnimationPlayer as AnimationPlayer


func _ready() -> void:
	($SignAnimation as AnimationPlayer).play("new_animation")

	($AudioStreamPlayer as AudioPlayer).fade_in(.8, 30.)
	($TransitionBase as Parts_TransitionBase).audio_player = $AudioStreamPlayer as AudioPlayer
	InputHelper.force_focus(self)
	
	
	Helper.preload_scene(settings_SCpath)
	Helper.preload_scene(collection_SCpath)


func _unhandled_input(event: InputEvent) -> void:
	InputHelper.force_grab_focus_on_input(event, self)


func _on_button_seets_pressed() -> void:
	var settings_screen: UiSettings = (await Helper.load_scene(settings_SCpath)).instantiate()
	print("ready")
	_camera_anim.play("camera_to_settings", -1, 1)
	_camera_anim.animation_finished.connect(
		func(_n: StringName) -> void: add_child.call_deferred(settings_screen), ConnectFlags.CONNECT_ONE_SHOT
	)
	_on_open_subscreen()
	settings_screen.on_close.connect(
		func() -> void:
			_camera_anim.play("camera_to_settings", -1, -1, true)
			_camera_anim.animation_finished.connect(func(_n: StringName) -> void: _on_close_subscreen(), ConnectFlags.CONNECT_ONE_SHOT)
			remove_child(settings_screen)
			settings_screen.queue_free()
	)


func _on_button_coll_pressed() -> void:
	print(121212)
	var coll_screen: UiIntroCollection = (await Helper.load_scene(collection_SCpath)).instantiate()
	print(55555)
	_camera_anim.play("camera_to_settings", -1, 1)
	_camera_anim.animation_finished.connect(
		func(_n: StringName) -> void: add_child.call_deferred(coll_screen), ConnectFlags.CONNECT_ONE_SHOT
	)

	_on_open_subscreen()
	coll_screen.on_close.connect(
		func() -> void:
			_camera_anim.play("camera_to_settings", -1, -1, true)
			_camera_anim.animation_finished.connect(func(_n: StringName) -> void: _on_close_subscreen(), ConnectFlags.CONNECT_ONE_SHOT)
			remove_child(coll_screen)
			coll_screen.queue_free()
	)


func _on_open_subscreen() -> void:
	($Node/MainMenuWrap as Control).hide()
	InputHelper.disable($Node/MainMenuWrap as Control)


func _on_close_subscreen() -> void:
	($Node/MainMenuWrap as Control).show()
	InputHelper.enable($Node/MainMenuWrap as Control)


func _on_button_play_pressed() -> void:
	var scene := preload("res://scene/board.tscn")
	var tween := create_tween()
	tween.tween_property($"Node/AnimationPlayer/Camera3D", "rotation:x", .02, .2)
	tween.tween_property($"Node/AnimationPlayer/Camera3D", "rotation:x", -1., ($TransitionBase as Parts_TransitionBase).length * 2)

	($TransitionBase as Parts_TransitionBase).swap_to(scene)


func _on_quit_button_pressed() -> void:
	var conf := $Confirm.duplicate() as PartsConfirm
	conf.message = "Are you sure?"
	conf.yeah_label = "Yeah close this"
	conf.nah_label = "Actually no, go back!!!"
	add_child(conf)
	_on_open_subscreen()
	conf.confirm(func() -> void: get_tree().quit(), func() -> void: _on_close_subscreen())

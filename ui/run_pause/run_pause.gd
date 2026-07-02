class_name UiRunPause
extends Control

const ROTATE_BY = .1

signal was_unpause_requested

var _loader := Loader.new()
@onready var _settings_scn_path := ($SettingsScn as InstancePlaceholder).get_instance_path()
@onready var _inventory_scn_path := ($InventoryScn as InstancePlaceholder).get_instance_path()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_loader.queue_resource(_settings_scn_path)
	_loader.queue_resource(_inventory_scn_path)
	get_tree().paused = true
	_on_close_subscreen()

	var pop_tween := create_tween()
	pop_tween.set_trans(Tween.TRANS_BACK)
	pop_tween.set_ease(Tween.EASE_IN_OUT)
	pop_tween.tween_property($VBoxContainer/TextureRect as Control, "offset_transform_scale", Vector2.ONE, .6).from(Vector2.ONE * .6)
	pop_tween.parallel().tween_property($VBoxContainer/TextureRect as Control, "modulate:a", 1, .6).from(0)

	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($VBoxContainer/TextureRect as Control, "offset_transform_rotation", ROTATE_BY, 6).from(-ROTATE_BY)
	tween.tween_property($VBoxContainer/TextureRect as Control, "offset_transform_rotation", -ROTATE_BY, 6).from(ROTATE_BY)


func _unhandled_input(event: InputEvent) -> void:
	InputHelper.force_grab_focus_on_input(event, self)


func _on_open_subscreen() -> void:
	($VBoxContainer as Control).focus_behavior_recursive = Control.FocusBehaviorRecursive.FOCUS_BEHAVIOR_DISABLED
	($VBoxContainer as Control).mouse_behavior_recursive = Control.MouseBehaviorRecursive.MOUSE_BEHAVIOR_DISABLED


func _on_close_subscreen() -> void:
	($VBoxContainer as Control).focus_behavior_recursive = Control.FocusBehaviorRecursive.FOCUS_BEHAVIOR_INHERITED
	($VBoxContainer as Control).mouse_behavior_recursive = Control.MouseBehaviorRecursive.MOUSE_BEHAVIOR_INHERITED
	InputHelper.force_focus($VBoxContainer as Control)


func _on_unpause() -> void:
	was_unpause_requested.emit()
	get_tree().paused = false


func _on_seets_button_pressed() -> void:
	var settings: UiSettings = _loader.get_resource(_settings_scn_path).instantiate()
	_on_open_subscreen()
	settings.on_close.connect(
		func() -> void:
			_on_close_subscreen()
			remove_child(settings)
			settings.queue_free()
	)
	add_child(settings)


func _on_inventory_button_pressed() -> void:
	var inventory: UiInventory = _loader.get_resource(_inventory_scn_path).instantiate()
	_on_open_subscreen()
	inventory.on_close.connect(
		func() -> void:
			_on_close_subscreen()
			remove_child(inventory)
			inventory.queue_free()
	)
	add_child(inventory)


func _on_quit_btn_pressed() -> void:
	get_tree().quit()

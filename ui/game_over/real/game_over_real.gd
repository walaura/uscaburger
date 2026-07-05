class_name UiGameOverReal
extends Control

var _tween: Tween
var _tween2: Tween

var _loader := Loader.new()
@onready var _inventory_scn_path := (%Inventory as InstancePlaceholder).get_instance_path()


func _ready_sc1() -> void:
	_loader.queue_resource(_inventory_scn_path)
	(%NextButton as Button).modulate.a = .0
	(%NextButton as Button).disabled = true
	(%NextButton as Button).focus_mode = Control.FOCUS_NONE

	var tween := (
		(%ScoresTkt as UiGameOver_ScoresTkt)
		. play_intro(
			CurrentRun.score.last_settled_score,
		)
	)
	tween.finished.connect(
		func() -> void:
			_tween = TweenHelper.maybe_init(self, _tween)
			(%NextButton as Button).disabled = false
			(%NextButton as Button).focus_mode = Control.FOCUS_ALL
			InputHelper.force_focus.call_deferred(self)
			_tween.tween_property(%NextButton as Button, "modulate:a", 1., .5)
	)


func _ready_sc2() -> void:
	_tween2 = TweenHelper.maybe_init(self, _tween, Tween.EASE_OUT)
	(%RecordsList as UiGameOverRealRecordsList).animate_in()
	pass


func _input(event: InputEvent) -> void:
	TweenHelper.wire_skip(_tween, event)


func _ready() -> void:
	if get_tree().current_scene == self:
		CurrentRun.inventory.hold_item((load("res://data/unlockables/ketchup.tres") as RsRawItem).apply_tier(1))
		var handler := ScTower_State.new()
		handler._push_line("XX", -21000)
		CurrentRun.score.settle(handler)
	get_tree().paused = true

	_tween = TweenHelper.maybe_init(self, _tween)
	_ready_sc1()


func _on_try_again_button_pressed() -> void:
	get_tree().paused = false

	($TransitionBase as Parts_TransitionBase).swap_to(preload("uid://e1vyixvrx7xi"))


func _on_next_button_pressed() -> void:
	_tween = TweenHelper.maybe_init(self, _tween, Tween.EASE_OUT)
	($CenterContainer/VBoxContainer as Control).offset_transform_enabled = true
	($CenterContainer/VBoxContainer2 as Control).offset_transform_enabled = true
	($CenterContainer/VBoxContainer2 as Control).modulate.a = 0.
	($CenterContainer/VBoxContainer2 as Control).visible = true

	_tween.tween_property($CenterContainer/VBoxContainer as Control, "offset_transform_position:x", -300, .5)
	_tween.parallel().tween_property($CenterContainer/VBoxContainer as Control, "modulate:a", 0., .5)
	_tween.parallel().tween_callback(func() -> void: _ready_sc2()).set_delay(.25)
	_tween.parallel().tween_property($CenterContainer/VBoxContainer2 as Control, "offset_transform_position:x", 0, .5).from(300).set_delay(
		.25
	)
	_tween.parallel().tween_property($CenterContainer/VBoxContainer2 as Control, "modulate:a", 1., .5).from(0.).set_delay(.25)


func _on_open_subscreen() -> void:
	($CenterContainer as Control).focus_behavior_recursive = Control.FocusBehaviorRecursive.FOCUS_BEHAVIOR_DISABLED
	($CenterContainer as Control).mouse_behavior_recursive = Control.MouseBehaviorRecursive.MOUSE_BEHAVIOR_DISABLED


func _on_close_subscreen() -> void:
	($CenterContainer as Control).focus_behavior_recursive = Control.FocusBehaviorRecursive.FOCUS_BEHAVIOR_INHERITED
	($CenterContainer as Control).mouse_behavior_recursive = Control.MouseBehaviorRecursive.MOUSE_BEHAVIOR_INHERITED
	InputHelper.force_focus($CenterContainer as Control)


func _on_stats_button_pressed() -> void:
	var inventory: UiInventory = _loader.get_resource(_inventory_scn_path).instantiate()
	_on_open_subscreen()
	inventory.on_close.connect(
		func() -> void:
			_on_close_subscreen()
			remove_child(inventory)
			inventory.queue_free()
	)
	add_child(inventory)

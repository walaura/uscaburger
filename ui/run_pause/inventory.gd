class_name UiInventory
extends Control

signal on_close

var _live_panels: Array[Control]
var _loader := Loader.new()

@onready var INVENTORY_ITEM_DETAILS_PATH := ($InventoryItemDetails as InstancePlaceholder).get_instance_path()
@onready var INVENTORY_STATS_FX_PATH := ($InventoryStatsFx as InstancePlaceholder).get_instance_path()


func _on_hide_show_button_pressed() -> void:
	($PaperWindow as UiKetchupPaperWindow).animate_out().finished.connect(func() -> void: on_close.emit())


func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		_on_hide_show_button_pressed()


func _ready() -> void:
	_loader.queue_resource(INVENTORY_ITEM_DETAILS_PATH)
	_loader.queue_resource(INVENTORY_STATS_FX_PATH)

	($PaperWindow as UiKetchupPaperWindow).animation_in_almost_ready.connect(
		func() -> void: (%InventoryHeld as UiInventoryHeld).animate_in()
	)

	(%SidePanel as Control).hide()
	($ButtonPrompts as UiButtonPrompts).visible = true
	($ButtonPrompts as UiButtonPrompts).push("ui_cancel")
	find_next_valid_focus().grab_focus.call_deferred()

	(%InventoryHeld as UiInventoryHeld).on_item_hovered.connect(_on_item_hovered)
	(%InventoryHeld as UiInventoryHeld).on_fx_hovered.connect(_on_fx_hovered)


func _clear_live_panels() -> void:
	for panel in _live_panels:
		var out_tween := create_tween()
		out_tween.tween_property(panel, "offset_transform_position:x", 400., .4)
		out_tween.finished.connect(
			func() -> void:
				if not panel.is_queued_for_deletion():
					panel.queue_free()
		)
	_live_panels.clear()


func _spawn_panel(contents: Control, color := Color("#00161c")) -> void:
	var clone: Control = %SidePanel.duplicate()
	clone.visible = true
	var bg := clone.get_child(0) as ColorRect
	_clear_live_panels()

	bg.material.set("shader_parameter/ColorParameter", color)

	contents.set_anchors_and_offsets_preset(LayoutPreset.PRESET_FULL_RECT)
	contents.offset_left = 8.
	contents.offset_right = 0
	clone.add_child(contents)
	%SidePanel.get_parent().add_child(clone)

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(clone, "offset_transform_position:x", 0., .4).from(400.)

	var bg_tween := create_tween()
	bg_tween.set_loops()
	bg_tween.set_parallel()
	bg_tween.tween_property(bg.material, "shader_parameter/MaskSlop", -1, 50.).from(0.)
	bg_tween.tween_property(bg.material, "shader_parameter/Bg_Scroll", 1, 80.).from(0.)

	_live_panels.push_back(clone)


func _on_item_hovered(item: RsUnlockable) -> void:
	var instance := _loader.get_resource(INVENTORY_ITEM_DETAILS_PATH).instantiate() as UiInventoryItemDetails
	instance.item = item
	_spawn_panel(instance, Color("#1b1c10"))


func _on_fx_hovered() -> void:
	var instance := _loader.get_resource(INVENTORY_STATS_FX_PATH).instantiate() as UiInventoryStatsFx
	_spawn_panel(instance)

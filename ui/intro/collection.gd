class_name UiIntroCollection
extends Control

signal on_close

var _live_panels: Array[UiKetchupPaperWindowPanel]
var _loader := Loader.new()
var _case := UiKetchupBadgeGrid.new()

@onready var INVENTORY_ITEM_DETAILS_PATH := ($InventoryItemDetails as InstancePlaceholder).get_instance_path()


func _on_hide_show_button_pressed() -> void:
	($PaperWindow as UiKetchupPaperWindow).animate_out().finished.connect(func() -> void: on_close.emit())


func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		_on_hide_show_button_pressed()


func _ready() -> void:
	_loader.queue_resource(INVENTORY_ITEM_DETAILS_PATH)

	($PaperWindow as UiKetchupPaperWindow).animation_in_almost_ready.connect(
		func() -> void:
			_case.focus_index(0)
			_case.animate_in()
	)
	($ButtonPrompts as UiButtonPrompts).visible = true
	($ButtonPrompts as UiButtonPrompts).push("ui_cancel")

	_case.columns = 5
	var all_held_items := CurrentRun.inventory.get_all_possible_holdable_items_as_uniques()
	_case.animate_on_ready = false
	_case.badges = []
	_case.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_case.size_flags_vertical = Control.SIZE_EXPAND_FILL

	for item in all_held_items:
		var badge := (load((%Badge as InstancePlaceholder).get_instance_path()) as PackedScene).instantiate() as UiKetchupBadge
		var icon := UiKetchupBadgeGridIcon.new()
		badge.icon = item.icon
		badge.tier = item.get_tier_for_display()
		icon.badge = badge

		icon.on_item_hovered.connect(func() -> void: _on_item_hovered(item))
		_case.badges.append(icon)

	(%VBoxContainer).add_child(_case)


func _clear_live_panels() -> void:
	for panel in _live_panels:
		panel.animate_out()
	_live_panels.clear()


func _spawn_panel(contents: Control, color := Color("#00161c")) -> void:
	_clear_live_panels()
	var clone: UiKetchupPaperWindowPanel = %PaperWindowPanel.duplicate()
	clone.visible = true
	_live_panels.append(clone)

	%Control.add_child(clone)
	clone.animate_in(contents, color)


func _on_item_hovered(item: RsItem) -> void:
	var instance := _loader.get_resource(INVENTORY_ITEM_DETAILS_PATH).instantiate() as UiInventoryItemDetails
	instance.item = item
	_spawn_panel(instance, Color("#1b1c10"))

class_name UiInventory
extends Control

signal on_close

var _live_panels: Array[UiKetchupPaperWindowPanel]
var _loader := Loader.new()

@onready var INVENTORY_ITEM_DETAILS_PATH := ($InventoryItemDetails as InstancePlaceholder).get_instance_path()
@onready var INVENTORY_STATS_FX_PATH := ($InventoryStatsFx as InstancePlaceholder).get_instance_path()
@onready var INVENTORY_PEDIA_PATH := ($InventoryStatsPedia as InstancePlaceholder).get_instance_path()


func _on_hide_show_button_pressed() -> void:
	($PaperWindow as UiKetchupPaperWindow).animate_out().finished.connect(func() -> void: on_close.emit())


func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		_on_hide_show_button_pressed()


func _ready() -> void:
	_loader.queue_resource(INVENTORY_ITEM_DETAILS_PATH)
	_loader.queue_resource(INVENTORY_STATS_FX_PATH)
	_loader.queue_resource(INVENTORY_PEDIA_PATH)

	($PaperWindow as UiKetchupPaperWindow).animation_in_almost_ready.connect(
		func() -> void: (%InventoryHeld as UiInventoryHeld).animate_in()
	)
	($ButtonPrompts as UiButtonPrompts).visible = true
	($ButtonPrompts as UiButtonPrompts).push("ui_cancel")
	#TODO find_next_valid_focus().grab_focus.call_deferred()

	(%InventoryHeld as UiInventoryHeld).on_item_hovered.connect(_on_item_hovered)
	(%InventoryHeld as UiInventoryHeld).on_fx_hovered.connect(_on_fx_hovered)
	(%InventoryHeld as UiInventoryHeld).on_pedia_hovered.connect(_on_pedia_hovered)


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


func _on_fx_hovered() -> void:
	var instance := _loader.get_resource(INVENTORY_STATS_FX_PATH).instantiate() as Control
	_spawn_panel(instance)


func _on_pedia_hovered() -> void:
	var instance := _loader.get_resource(INVENTORY_PEDIA_PATH).instantiate() as Control
	_spawn_panel(instance, Color("1c1010ff"))

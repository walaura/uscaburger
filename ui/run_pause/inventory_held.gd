class_name UiInventoryHeld
extends Control

signal on_item_hovered(item: RsUnlockableWTier)
signal on_fx_hovered

@export var animate_on_ready := true

var _top := UiKetchupBadgeGrid.new()
var _bottom := UiKetchupBadgeGrid.new()


func animate_in() -> void:
	_top.focus_index(0)
	_bottom.animate_in()


func _ready() -> void:
	_top.columns = 5
	_bottom.columns = 5
	var all_held_items := CurrentRun.inventory.get_all_held_items_as_uniques()
	_top.animate_on_ready = true

	var top_icon := UiKetchupBadgeGridIcon.new()
	top_icon.badge = $RunFxBtn as Control
	top_icon.on_item_hovered.connect(on_fx_hovered.emit)
	_top.badges = [top_icon]

	($VBoxContainer).add_child(_top)

	_bottom.animate_on_ready = false
	_bottom.badges = []

	for item in all_held_items:
		var badge := (load((%Badge as InstancePlaceholder).get_instance_path()) as PackedScene).instantiate() as UiKetchupBadge
		var icon := UiKetchupBadgeGridIcon.new()
		icon.badge = badge
		badge.icon = item.icon
		badge.tier = item.tier

		icon.on_item_hovered.connect(func() -> void: on_item_hovered.emit(item))
		_bottom.badges.append(icon)

	($VBoxContainer).add_child(_bottom)
	if animate_on_ready:
		animate_in()

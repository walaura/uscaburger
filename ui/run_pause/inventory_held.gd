class_name UiInventoryHeld
extends Control

signal on_item_hovered(item: RsUnlockable)
signal on_fx_hovered

@export var animate_on_ready := true

var _pop_tween: Tween
@onready var _icon_size := size.x / (%GridContainer as GridContainer).columns


func animate_in() -> void:
	_pop_tween.play()


func _make_icon(badge: Control, on_focus: Callable) -> Control:
	var badge_stamp := (
		((load((%BadgeWStamp as InstancePlaceholder).get_instance_path()) as PackedScene).instantiate()) as UiKetchupBadgeWStamp
	)
	badge_stamp.badge = badge
	var button := Button.new()
	var container := Control.new()

	button.modulate.a = 0.
	for item: Control in [container, badge_stamp, badge]:
		item.custom_minimum_size = Vector2.ONE * _icon_size
		item.custom_maximum_size = Vector2.ONE * _icon_size
	container.add_child(badge_stamp)
	container.add_child(button)
	button.set_anchors_and_offsets_preset(LayoutPreset.PRESET_FULL_RECT)
	container.set_anchors_and_offsets_preset(LayoutPreset.PRESET_FULL_RECT)
	button.focus_entered.connect(
		func() -> void:
			on_focus.call()
			badge_stamp._on_mouse_entered()
	)
	button.focus_exited.connect(func() -> void: badge_stamp._on_mouse_exited())
	button.mouse_entered.connect(func() -> void: button.grab_focus())
	button.mouse_exited.connect(func() -> void: button.release_focus())

	return container


func _ready() -> void:
	var all_held_items := CurrentRun.inventory.get_all_held_items_as_uniques()
	_pop_tween = create_tween()

	if animate_on_ready == false:
		_pop_tween.pause()


	($VBoxContainer/Button).add_sibling(_make_icon($RunFxBtn as Control, on_fx_hovered.emit))
	($VBoxContainer/Button).queue_free()
	for item in all_held_items:
		var badge := (load((%Badge as InstancePlaceholder).get_instance_path()) as PackedScene).instantiate() as UiKetchupBadge
		badge.icon = item.icon
		badge.animates = false
		badge.tier = item._tier
		_pop_tween.tween_callback(badge.animate_in).set_delay(.1)
		%GridContainer.add_child(_make_icon(badge, func() -> void: on_item_hovered.emit(item)))


func _on_button_stats_mouse_entered() -> void:
	on_fx_hovered.emit()

class_name UiKetchupBadgeGridIcon
extends Control

var badge: Control

const STAMP_SCN := preload("uid://d0q5130h1d0sy") as PackedScene
var _button := Button.new()

signal on_item_hovered


func grab_innie_focus() -> void:
	_button.grab_focus()


func _ready() -> void:
	var badge_stamp := (STAMP_SCN.instantiate()) as UiKetchupBadgeWStamp
	badge_stamp.badge = badge

	_button.modulate.a = 0.
	for item: Control in [self, badge_stamp, badge, _button]:
		item.set_anchors_and_offsets_preset(LayoutPreset.PRESET_FULL_RECT)
	add_child(badge_stamp)
	add_child(_button)
	_button.focus_entered.connect(
		func() -> void:
			on_item_hovered.emit()
			badge_stamp._on_mouse_entered()
	)
	_button.focus_exited.connect(func() -> void: badge_stamp._on_mouse_exited())
	_button.mouse_entered.connect(_button.grab_focus)
	_button.mouse_exited.connect(_button.release_focus)

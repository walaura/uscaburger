extends Control

class_name ButtonPromptForAction

const ASSET_BTN_BUMPER_R = preload("res://asset/ui/btn-bumper-r.png")
const ASSET_BTN_BUMPER_L = preload("res://asset/ui/btn-bumper-l.png")
const ASSET_BTN_CIRCLE_A = preload("res://asset/ui/btn-circle-a.png")
const ASSET_BTN_CIRCLE_B = preload("res://asset/ui/btn-circle-b.png")
const ASSET_BTN_CIRCLE_X = preload("res://asset/ui/btn-circle-x.png")
const ASSET_BTN_CIRCLE_Y = preload("res://asset/ui/btn-circle-y.png")
const ASSET_BTN_MYSTERY = preload("res://asset/ui/btn-mystery.png")
const ASSET_BTN_KEEB_F = preload("res://asset/ui/btn-keeb-f.png")
const ASSET_BTN_KEEB_R = preload("res://asset/ui/btn-keeb-r.png")
const ASSET_BTN_KEEB_SPACE = preload("res://asset/ui/btn-keeb-space.png")
const ASSET_BTN_KEEB_TAB = preload("res://asset/ui/btn-keeb-tab.png")

@export var action: String:
	set(value):
		action = value
		_set_action()


func get_joypad_asset(index: int) -> Texture2D:
	match index:
		0:
			return ASSET_BTN_CIRCLE_A
		1:
			return ASSET_BTN_CIRCLE_B
		2:
			return ASSET_BTN_CIRCLE_X
		3:
			return ASSET_BTN_CIRCLE_Y
		9:
			return ASSET_BTN_BUMPER_L
		10:
			return ASSET_BTN_BUMPER_R
		_:
			return ASSET_BTN_MYSTERY


func get_key_asset(index: int) -> Texture2D:
	match index:
		32:
			return ASSET_BTN_KEEB_SPACE
		82:
			return ASSET_BTN_KEEB_R
		70:
			return ASSET_BTN_KEEB_F
		4194306:
			return ASSET_BTN_KEEB_TAB
		_:
			return ASSET_BTN_MYSTERY


func _set_action() -> void:
	var rect := get_child(0) as ColorRect
	rect.material.set("shader_parameter/ColorParameter", Vector3(1, 1, 1))
	var asset := ASSET_BTN_MYSTERY

	rect.material.set("shader_parameter/Texture2DParameter", asset)

	for event in InputMap.action_get_events(action):
		if Helper.is_joypad && event is InputEventJoypadButton:
			asset = get_joypad_asset((event as InputEventJoypadButton).button_index)
		elif event is InputEventKey:
			asset = get_key_asset((event as InputEventKey).physical_keycode)

	rect.material.set("shader_parameter/Texture2DParameter", asset)

	if is_wider(asset):
		custom_minimum_size.x = size.y * 1.33333
	else:
		custom_minimum_size.x = size.y


func is_wider(asset: Texture2D) -> bool:
	match asset:
		ASSET_BTN_BUMPER_L, ASSET_BTN_BUMPER_R, ASSET_BTN_KEEB_F, ASSET_BTN_KEEB_R, ASSET_BTN_KEEB_SPACE, ASSET_BTN_KEEB_TAB:
			return true
		_:
			return false


func _ready() -> void:
	Helper.on_joypad_shape_changed.connect(func(_shape: Variant) -> void: _set_action())

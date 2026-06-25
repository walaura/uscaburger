extends Node

signal is_debug_changed

const DROP_TIMEOUT = .5
const WAVE_MAX_OFFSET = 2
const WAVE_SPEED_TIMER_SPEED = 3
const ITEM_Y_SCALE = 1

const COLOR_RED := Color("ff3314")

var anim_lib: AnimationLibrary = preload("res://asset/animations.res")

var is_debug := false:
	set(val):
		is_debug = val
		is_debug_changed.emit()

@onready var stock := ResourceLoader.list_directory("res://data/unlockables")


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func format_number_with_commas(number: int) -> String:
	var num_str: String = str(abs(number))
	var result: String = ""
	var count: int = 0

	for i in range(num_str.length() - 1, -1, -1):
		result = num_str[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result

	if number < 0:
		result = "- " + result

	return result


signal on_joypad_shape_changed(is_joypad: bool)
var is_joypad := false:
	set(value):
		if value != is_joypad:
			is_joypad = value
			on_joypad_shape_changed.emit(value)
		else:
			is_joypad = value


func _input(event: InputEvent) -> void:
	is_joypad = event is InputEventJoypadMotion or event is InputEventJoypadButton
	if event.is_action_released("DBG-Splort"):
		is_debug = not is_debug


func format_number(number: float) -> String:
	var decls := fmod(number, 1)
	var start := format_number_with_commas(int(number))
	return start + "." + ("%02d" % abs(decls * 100))


func format_currency(number: float) -> String:
	return "$ " + Helper.format_number(number / 100.)


func add_animation(node: Node) -> AnimationPlayer:
	var player := AnimationPlayer.new()
	node.add_child(player)
	player.add_animation_library("animations", anim_lib)
	return player


func get_screen_rect(aabb: AABB) -> Rect2:
	# 1. Get the active camera from the viewport globals
	var camera := get_viewport().get_camera_3d()
	if not camera:
		return Rect2()

	var p := aabb.position
	var s := aabb.size

	var corners: Array[Vector3] = [
		p,
		p + Vector3(s.x, 0, 0),
		p + Vector3(s.x, 0, s.z),
		p + Vector3(0, 0, s.z),
		p + Vector3(0, s.y, 0),
		p + Vector3(s.x, s.y, 0),
		p + Vector3(s.x, s.y, s.z),
		p + Vector3(0, s.y, s.z),
	]

	var min_pos: Vector2 = Vector2(INF, INF)
	var max_pos: Vector2 = Vector2(-INF, -INF)

	for corner in corners:
		var global_pt := corner

		if camera.is_position_behind(global_pt):
			continue

		var screen_pt := camera.unproject_position(global_pt)

		min_pos.x = min(min_pos.x, screen_pt.x)
		min_pos.y = min(min_pos.y, screen_pt.y)
		max_pos.x = max(max_pos.x, screen_pt.x)
		max_pos.y = max(max_pos.y, screen_pt.y)

	return Rect2(min_pos, max_pos - min_pos)


func get_item_raw(file_name: String) -> UnlockableResource:
	return load("res://data/unlockables/" + file_name)


func get_all_items() -> PackedStringArray:
	return stock


func get_purchasable_items() -> Array[String]:
	var keys: Array[String] = []
	var all_keys: Array[String] = Array(Array(get_all_items()), TYPE_STRING, "", null)
	all_keys = all_keys.filter(
		func(item: String) -> bool:
			var raw := get_item_raw(item)
			if raw.requires.size() == 0:
				return true
			for requisite in raw.requires:
				if !CurrentRunState.inventory_handler.is_holding_item(requisite):
					return false
			return true
	)
	for key in all_keys:
		if get_item_raw(key).is_incremental == true:
			keys.push_back(key)
		elif !CurrentRunState.inventory_handler.is_holding_item(key):
			keys.push_back(key)
	return keys

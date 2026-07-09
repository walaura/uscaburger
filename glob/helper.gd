extends Node

signal is_debug_changed

const DROP_TIMEOUT = .5
const WAVE_MAX_OFFSET = 2
const WAVE_SPEED_TIMER_SPEED = 3
const ITEM_Y_SCALE = 1
const MIN_TO_CLOSE = 6

var anim_speed := 1.

const COLORS := preload("res://data/colors.tres") as ColorPalette

var COLOR_RED := COLORS.colors.get(0)
var COLOR_TEAL := COLORS.colors.get(1)
var COLOR_TEAL_DARKER := COLORS.colors.get(2)
var COLOR_YELL := COLORS.colors.get(3)

var anim_lib: AnimationLibrary = preload("res://asset/animations.res")

var is_debug := false:
	set(val):
		is_debug = val
		anim_speed = .25 if is_debug else 1.
		is_debug_changed.emit()


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
	if event.is_action_released("ui_fs"):
		var screen_mode := SavedData.get_gfx_int_setting(SavedData.Options.SCREEN_MODE)
		SavedData.apply_gfx_setting(SavedData.Options.SCREEN_MODE, 1 if screen_mode == 0 else 0)


func format_number(number: float) -> String:
	var decls := fmod(number, 1)
	var start := format_number_with_commas(int(number))
	var minus := "-" if number < 0 else ""
	return minus + start + "." + ("%02d" % abs(decls * 100))


func get_units() -> int:
	return CurrentRun.inventory._get_held_item_by_key_tier("currency_fx.tres") % 3


func format_unix_date(number: float) -> String:
	var dict := Time.get_datetime_dict_from_unix_time(int(number))
	return get_month_from_index(dict["month"]) + " " + str(dict["day"]) + ", " + str(dict["year"])


func get_month_from_index(index: Variant) -> String:
	match index:
		1:
			return "January"
		2:
			return "February"
		3:
			return "March"
		4:
			return "April"
		5:
			return "May"
		6:
			return "June"
		7:
			return "July"
		8:
			return "August"
		9:
			return "September"
		10:
			return "October"
		11:
			return "November"
		_:
			return "December"


func format_currency(number: float) -> String:
	var tier := get_units()

	match tier:
		1:
			return Helper.format_number((number * 1.2) / 100.) + "€"
		2:
			if absf(number) < 100:
				return "%dp" % (number)
			return "£" + Helper.format_number((number * 1.5) / 100.)
		_:
			if absf(number) < 100:
				return "%d¢" % (number)
			return "$" + Helper.format_number(number / 100.)


func format_size(units: float) -> String:
	var number := size_in_units(units)
	if get_units() == 1:
		return "%.2f" % (number) + " cm"

	return "%.2f" % (number) + " in"


func size_in_units(units: float) -> float:
	if get_units() == 1:
		return units * 3.75

	return units * 1.5


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


func load_scene(path: String) -> PackedScene:
	var error := ResourceLoader.load_threaded_request(path, type_string(typeof(PackedScene)))

	if error != Error.OK:
		print(error)
		return null

	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame

	var status := ResourceLoader.load_threaded_get_status(path)
	if status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		print(status)
		return null

	var packed_scene := ResourceLoader.load_threaded_get(path)
	return packed_scene as PackedScene

class_name InputHelper
extends RefCounted

var _input_toggle_timeout: Dictionary[String, int] = {}
var _input_toggle_status: Dictionary[String, bool] = {}


func handle_toggle(event: InputEvent, action: StringName, on_active: Callable, on_dective: Callable) -> void:
	if event.is_action_pressed(action):
		_input_toggle_timeout[action] = Time.get_ticks_msec()
		if _input_toggle_status.get_or_add(action, false) != true:
			on_active.call()
	if event.is_action_released(action):
		var elapsed_time := Time.get_ticks_msec() - _input_toggle_timeout[action]
		if elapsed_time < 200:
			if _input_toggle_status.get_or_add(action, false) == true:
				on_dective.call()
			else:
				on_active.call()
			_input_toggle_status[action] = !_input_toggle_status.get_or_add(action, false)
		else:
			on_dective.call()


static func force_grab_focus_on_input(event: InputEvent, root_control: Control) -> void:
	if (
		event.is_action("ui_down")
		or event.is_action("ui_up")
		or event.is_action("ui_left")
		or event.is_action("ui_accept")
		or event.is_action("ui_right")
	):
		if root_control.get_viewport().gui_get_focus_owner() == null:
			force_focus(root_control)


static func force_focus(root_control: Control) -> void:
	var control := root_control.find_next_valid_focus()
	if control != null:
		control.grab_focus.call_deferred()
	else:
		printerr("no control to focus??>??", root_control)


static func enable(node: Control) -> void:
	node.focus_behavior_recursive = Control.FocusBehaviorRecursive.FOCUS_BEHAVIOR_INHERITED
	node.mouse_behavior_recursive = Control.MouseBehaviorRecursive.MOUSE_BEHAVIOR_INHERITED
	InputHelper.force_focus(node)


static func disable(node: Control) -> void:
	(node).focus_behavior_recursive = Control.FocusBehaviorRecursive.FOCUS_BEHAVIOR_DISABLED
	(node).mouse_behavior_recursive = Control.MouseBehaviorRecursive.MOUSE_BEHAVIOR_DISABLED

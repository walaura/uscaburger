class_name InputHelper
extends RefCounted


static func force_grab_focus_on_input(event: InputEvent, root_control: Control) -> void:
	if event.is_action("ui_down") or event.is_action("ui_up") or event.is_action("ui_left") or event.is_action("ui_accept") or event.is_action("ui_right"):
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

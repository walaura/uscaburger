extends Node2D

class_name VisibleOnDev

func _init() -> void:
	_set_ui()
	Helper.is_debug_changed.connect(_set_ui)


func _set_ui() -> void:
	visible = Helper.is_debug
	process_mode = Node.PROCESS_MODE_ALWAYS if Helper.is_debug else Node.PROCESS_MODE_DISABLED

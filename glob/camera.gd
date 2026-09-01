extends Node

@export var GAMEPLAY_target: Node3D
@export var GAMEPLAY_dramatic_timer_zoom := 0.0
@export var ZOOM_OUT_AABB: AABB
@export var mode := Mode.GAMEPLAY:
	set(val):
		mode = val
		on_camera_mode_changed.emit()

enum Mode { GAMEPLAY, ZOOM_OUT }

signal on_camera_mode_changed


func set_mode_zoom_out(aabb: AABB) -> void:
	ZOOM_OUT_AABB = aabb
	mode = Mode.ZOOM_OUT


func set_mode_gameplay() -> void:
	mode = Mode.GAMEPLAY

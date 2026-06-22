extends Node

@export var GAMEPLAY_target: Node3D
@export var GAMEPLAY_dramatic_timer_zoom := 0.0

enum Mode { GAMEPLAY, ZOOM_OUT }
@export var mode := Mode.GAMEPLAY

@export var ZOOM_OUT_AABB: AABB


func set_mode_zoom_out(aabb: AABB) -> void:
	ZOOM_OUT_AABB = aabb
	mode = Mode.ZOOM_OUT


func set_mode_gameplay() -> void:
	mode = Mode.GAMEPLAY

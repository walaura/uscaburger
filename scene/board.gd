extends Node3D

var is_game_over := false
static var RUN_SCN := preload("res://scene/board/run.tscn")

var run_scn: ScRun


func _ready() -> void:
	run_scn = RUN_SCN.instantiate()
	add_child(run_scn)

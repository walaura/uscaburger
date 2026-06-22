extends Node3D

var is_game_over := false
static var RUN_SCN := preload("res://scene/run.tscn")

var run_scn: Run


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if (event as InputEventKey).pressed and (event as InputEventKey).keycode == KEY_ESCAPE:
			get_tree().quit()


func _ready() -> void:
	run_scn = RUN_SCN.instantiate()
	add_child(run_scn)

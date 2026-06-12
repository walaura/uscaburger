extends Node3D

var is_game_over := false
static var TOWER_SCN := preload("res://Object/burger_tower.tscn")

var track_cam_to: Variant = null

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _ready() -> void:
	var instance = TOWER_SCN.instantiate();
	instance.on_game_over.connect(on_game_over)
	instance.on_new_spawn.connect(on_new_spawn)
	add_child(instance)
	


func _process(delta: float) -> void:
	Dp.push('game over??', is_game_over)
	if(track_cam_to):
		var cam = find_child('Camera3D');
		cam.target = track_cam_to


func on_game_over():
	is_game_over = true

func on_new_spawn(part):
	track_cam_to = part;

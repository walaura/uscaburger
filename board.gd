extends Node3D

var is_game_over := false
static var TOWER_SCN := preload("res://object/burger_tower.tscn")
static var SCORE_HANDLER_SC := preload("res://object/run/score.gd")

var tower_scn: BurgerTower
var score_handler: Run_ScooreHandler


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()


func _init():
	score_handler = SCORE_HANDLER_SC.new()


func _ready() -> void:
	tower_scn = TOWER_SCN.instantiate()
	tower_scn.on_game_over.connect(on_game_over)
	tower_scn.on_new_spawn.connect(on_new_spawn)
	Camera.set_mode_gameplay()
	add_child(tower_scn)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Zoom-out"):
		Camera.set_mode_zoom_out(tower_scn.get_scene_aabb())
	if event.is_action_released("Zoom-out"):
		Camera.set_mode_gameplay()


func on_game_over(_did_finish: bool, tower_score_handler: BurgerTower_ScooreHandler):
	score_handler.push(tower_score_handler.current_session_score)
	var game_over_screen_p = preload("res://ui/game_over.tscn")
	var game_over_screen := game_over_screen_p.instantiate()
	game_over_screen.score_handler = score_handler
	add_child(game_over_screen)
	is_game_over = true


func on_new_spawn(part: Droppable):
	Camera.GAMEPLAY_target = part.get_child(0)

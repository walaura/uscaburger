extends Node3D

class_name Scene_Run

const GAME_OVER_SCENE_PATH: String = "res://ui/game_over.tscn"

static var TOWER_SCN := preload("res://scene/board/tower.tscn")
static var SCREEN_TS_TIME := .5

var tower_scn: Scene_Tower


func _ready() -> void:
	CurrentRunState.start_new_run()
	Camera.set_mode_gameplay()
	_instance_tower()


func _instance_tower() -> void:
	ResourceLoader.load_threaded_request(GAME_OVER_SCENE_PATH)
	tower_scn = TOWER_SCN.instantiate()
	tower_scn.on_game_over.connect(on_game_over)
	tower_scn.on_new_spawn.connect(on_new_spawn)

	add_child(tower_scn)
	tower_scn.position = Vector3(0, 0, 4)
	var tween := create_tween()
	(
			tween
			.tween_property(tower_scn, "position", Vector3(0, 0, 0), SCREEN_TS_TIME)
			.set_trans(Tween.TRANS_SINE)
			.set_ease(Tween.EASE_IN_OUT)
	)


func _play_again() -> void:
	var old_tower_scn := tower_scn
	old_tower_scn.process_mode = Node.PROCESS_MODE_DISABLED
	var tween := create_tween()
	tween.tween_property(tower_scn, "position", Vector3(10, 0, 0), SCREEN_TS_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).finished.connect(
		func() -> void: remove_child(old_tower_scn)
	)

	var timer := Timer.new()
	add_child(timer)
	timer.start(SCREEN_TS_TIME / 2)
	timer.timeout.connect(
		func() -> void:
			_instance_tower()
			remove_child(timer)
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Zoom-out"):
		Camera.set_mode_zoom_out(tower_scn.get_scene_aabb())
	if event.is_action_released("Zoom-out"):
		Camera.set_mode_gameplay()


func on_game_over(did_finish: bool, tower_score_handler: Scene_Tower_ScooreHandler) -> void:
	var scene_resource: PackedScene = ResourceLoader.load_threaded_get(GAME_OVER_SCENE_PATH)
	if scene_resource == null:
		printerr("failed to preload game over")
		ResourceLoader.load_threaded_request(GAME_OVER_SCENE_PATH)
		on_game_over(did_finish, tower_score_handler)
		return

	if did_finish:
		CurrentRunState.score_handler.settle(tower_score_handler.current_session_score)
	else:
		CurrentRunState.score_handler.settle_loss(tower_score_handler.current_session_score)
	var game_over_screen: UI_GameOver = scene_resource.instantiate()
	game_over_screen.on_next_round.connect(
		func() -> void:
			_play_again()
			remove_child(game_over_screen)
	)
	add_child(game_over_screen)


func on_new_spawn(part: Droppable) -> void:
	Camera.GAMEPLAY_target = part.get_child(0)

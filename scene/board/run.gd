class_name Scene_Run
extends Node3D

const GAME_OVER_SCENE_PATH := "uid://ufb8u4b13l1g"
const TOWER_SCENE: PackedScene = preload("uid://dj3d6kyexgqic")

static var SCREEN_TS_TIME := .5

var _tower_scn: Scene_Tower
var _maybe_force_next_mode: Scene_Tower.Mode


func _ready() -> void:
	CurrentRunState.start_new_run()
	Camera.set_mode_gameplay()
	_instance_tower()
	_DBG_set_up()

	CurrentRunState.inventory_handler.item_got_held.connect(
		func(item: String) -> void:
			match item:
				"alt_chicken.tres":
					_maybe_force_next_mode = Scene_Tower.Mode.Chicken
				"alt_vegan.tres":
					_maybe_force_next_mode = Scene_Tower.Mode.Vegan
	)


func _get_next_tower_mode() -> Scene_Tower.Mode:
	if _maybe_force_next_mode > 0:
		var rt := _maybe_force_next_mode
		@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
		_maybe_force_next_mode = -1
		return rt

	if CurrentRunState.inventory_handler.is_holding_item("alt_chicken.tres"):
		if randi_range(1, 10) == 10:
			return Scene_Tower.Mode.Chicken
	if CurrentRunState.inventory_handler.is_holding_item("alt_vegan.tres"):
		if randi_range(1, 10) == 10:
			return Scene_Tower.Mode.Vegan

	return Scene_Tower.Mode.Normal


func _instance_tower() -> void:
	ResourceLoader.load_threaded_request(GAME_OVER_SCENE_PATH)
	_tower_scn = TOWER_SCENE.instantiate()
	_tower_scn.setup(_get_next_tower_mode())
	_tower_scn.on_game_over.connect(on_game_over)
	_tower_scn.on_new_spawn.connect(on_new_spawn)

	add_child(_tower_scn)
	_tower_scn.position = Vector3(0, 0, 4)
	var tween := create_tween()
	(
		tween
		. tween_property(_tower_scn, "position", Vector3(0, 0, 0), SCREEN_TS_TIME)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_IN_OUT)
	)


func _play_again() -> void:
	var old_tower_scn := _tower_scn
	old_tower_scn.process_mode = Node.PROCESS_MODE_DISABLED
	var tween := create_tween()
	tween.tween_property(_tower_scn, "position", Vector3(10, 0, 0), SCREEN_TS_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).finished.connect(
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
		Camera.set_mode_zoom_out(_tower_scn.get_scene_aabb())
	if event.is_action_released("Zoom-out"):
		Camera.set_mode_gameplay()


func on_game_over(did_finish: bool, tower_score_handler: Scene_Tower_ScoreHandler) -> void:
	var scene_resource: PackedScene = ResourceLoader.load_threaded_get(GAME_OVER_SCENE_PATH)
	if scene_resource == null:
		printerr("failed to preload game over")
		ResourceLoader.load_threaded_request(GAME_OVER_SCENE_PATH)
		on_game_over(did_finish, tower_score_handler)
		return

	if did_finish:
		CurrentRunState.score_handler.settle(tower_score_handler)
	else:
		CurrentRunState.score_handler.settle_loss(tower_score_handler)
	var game_over_screen: UI_GameOver = scene_resource.instantiate()
	game_over_screen.did_finish = did_finish
	game_over_screen.on_next_round.connect(
		func() -> void:
			_play_again()
			remove_child(game_over_screen)
	)
	add_child(game_over_screen)


func on_new_spawn(part: Droppable) -> void:
	Camera.GAMEPLAY_target = part.get_child(0)


func _DBG_set_up() -> void:
	if Cheats == null:
		return
	Cheats.with_container(
		"run",
		func(container: Container) -> void:
			for key: Scene_Tower.Mode in Scene_Tower.Mode.values():
				var b := Button.new()
				b.text = "Next: " + Scene_Tower.Mode.find_key(key)
				b.pressed.connect(func() -> void: _maybe_force_next_mode = key)
				container.add_child(b)
	)

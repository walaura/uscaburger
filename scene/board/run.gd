class_name ScRun
extends Node3D

const GAME_OVER_SCPATH := "uid://ufb8u4b13l1g"
const GAME_OVER_REAL_SCPATH := "uid://cp3q0cbp4pcx"
const TOWER_SCENE: PackedScene = preload("uid://dj3d6kyexgqic")
const PAUSE_SCENE: PackedScene = preload("uid://dj7uoasswkjfc")

static var SCREEN_TS_TIME := .5

var _tower_scn: ScTower
var _maybe_force_next_mode: ScTower.Mode

var _loader := Loader.new()


func _ready() -> void:
	CurrentRun.start_new_run()
	Camera.set_mode_gameplay()
	_instance_tower()
	_DBG_set_up()

	CurrentRun.inventory.item_got_held.connect(
		func(item: RsItem) -> void:
			match item.get_key():
				"alt_chicken.tres":
					_maybe_force_next_mode = ScTower.Mode.Chicken
				"alt_vegan.tres":
					_maybe_force_next_mode = ScTower.Mode.Vegan
	)


func _get_next_tower_mode() -> ScTower.Mode:
	if _maybe_force_next_mode > 0:
		var rt := _maybe_force_next_mode
		@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
		_maybe_force_next_mode = -1
		return rt

	if CurrentRun.inventory.is_holding_key("alt_chicken.tres"):
		if randi_range(1, 10) == 10:
			return ScTower.Mode.Chicken
	if CurrentRun.inventory.is_holding_key("alt_vegan.tres"):
		if randi_range(1, 10) == 10:
			return ScTower.Mode.Vegan

	return ScTower.Mode.Normal


func _instance_tower() -> void:
	_loader.queue_resource(GAME_OVER_SCPATH)
	_tower_scn = TOWER_SCENE.instantiate()
	_tower_scn.setup(_get_next_tower_mode())
	_tower_scn.on_game_over.connect(on_game_over)

	add_child(_tower_scn)
	_tower_scn.position = Vector3(0, 0, 4)
	var tween := create_tween()
	tween.tween_property(_tower_scn, "position", Vector3(0, 0, 0), SCREEN_TS_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _play_again() -> void:
	var old_tower_scn := _tower_scn
	old_tower_scn.process_mode = Node.PROCESS_MODE_DISABLED
	var tween := create_tween()
	tween.tween_property(_tower_scn, "position", Vector3(10, 0, 0), SCREEN_TS_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).finished.connect(
		func() -> void:
			remove_child(old_tower_scn)
			old_tower_scn.queue_free()
	)

	var timer := Timer.new()
	add_child(timer)
	timer.start(SCREEN_TS_TIME / 2)
	timer.timeout.connect(
		func() -> void:
			_instance_tower()
			remove_child(timer)
			timer.queue_free()
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Zoom-out"):
		Camera.set_mode_zoom_out(_tower_scn.get_aabb())
	if event.is_action_released("Zoom-out"):
		Camera.set_mode_gameplay()
	if event.is_action("ui_pause"):
		var pause_scene := PAUSE_SCENE.instantiate() as UiRunPause
		pause_scene.was_unpause_requested.connect(func() -> void: remove_child.call_deferred(pause_scene))
		add_child(pause_scene)


func on_game_over(did_finish: bool, tower_score: ScTower_State) -> void:
	_loader.queue_resource(GAME_OVER_REAL_SCPATH)
	var SCresource: PackedScene = _loader.get_resource(GAME_OVER_SCPATH)

	var prev_score_was_under_zero := CurrentRun.score.current_session_score < 0.0
	if did_finish:
		CurrentRun.score.finalize_burger(tower_score.make_stats())
		CurrentRun.score.settle(tower_score)
	else:
		CurrentRun.score.settle_loss(tower_score)

	if prev_score_was_under_zero && CurrentRun.score.current_session_score < 0.0:
		_on_real_game_over()
		return

	var game_over_screen: UiGameOver = SCresource.instantiate()
	game_over_screen.did_finish = did_finish
	game_over_screen.on_next_round.connect(
		func() -> void:
			_play_again()
			remove_child(game_over_screen)
			game_over_screen.queue_free()
	)
	add_child(game_over_screen)


func _on_real_game_over() -> void:
	var SCresource: PackedScene = _loader.get_resource(GAME_OVER_REAL_SCPATH)
	($TransitionBase as Parts_TransitionBase).swap_to(SCresource)


func _DBG_set_up() -> void:
	if Cheats == null:
		return
	Cheats.with_container(
		"run",
		func(container: Container) -> void:
			for key: ScTower.Mode in ScTower.Mode.values():
				var b := Button.new()
				b.text = "Next: " + ScTower.Mode.find_key(key)
				b.pressed.connect(func() -> void: _maybe_force_next_mode = key)
				container.add_child(b)
	)

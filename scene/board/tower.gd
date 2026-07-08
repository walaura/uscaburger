class_name ScTower
extends Node3D

@onready var SCORE_OVERLAY_SCN := ($ScoreOverlay as InstancePlaceholder).get_instance_path()
@onready var XTOCLOSE_SCN := ($XToClose as InstancePlaceholder).get_instance_path()

@export var floor_collider: StaticBody3D
@export var mode := Mode.Normal

signal on_game_over(did_finish: bool, score: ScTower_State)

var parts_scn := ScTower_Parts.new()

var _loader := Loader.new()
var _active_renderer: ScTower_PartRenderer
var _score_overlay: UiScoreOverlay

@onready var _state := ScTower_State.new(mode)
@onready var _difficulty_numbers := RsDifficultyNumbers.new(mode)

enum Mode { Normal, Vegan, Chicken }


func _init() -> void:
	_loader.queue_resource(SCORE_OVERLAY_SCN)
	_loader.queue_resource(XTOCLOSE_SCN)


func _ready() -> void:
	_on_spawn()

	_score_overlay = _loader.get_resource(SCORE_OVERLAY_SCN).instantiate() as UiScoreOverlay
	_score_overlay.setup(mode)
	add_child(_score_overlay)

	parts_scn.position.y = 9999999.
	parts_scn.visible = false
	add_child(parts_scn)

	_update_paper_color()
	_DBG_set_up()

	on_game_over.connect(
		func(_is_success: bool, _sh: ScTower_State) -> void:
			if $ButtonPrompts != null && !$ButtonPrompts.is_queued_for_deletion():
				$ButtonPrompts.queue_free()
			if _score_overlay != null && _score_overlay.get_parent() != null:
				_score_overlay.get_parent().remove_child(_score_overlay)
				_score_overlay.queue_free()
	)


func get_aabb() -> AABB:
	var total_aabb: AABB
	var first_box := true

	# Helper array to process nodes iteratively to avoid recursion limits
	var nodes_to_process: Array[Node] = %Stack.get_children()
	nodes_to_process.pop_back()
	while nodes_to_process.size() > 0:
		var current_node: Node = nodes_to_process.pop_back()

		# Check if the current node is a VisualInstance (like MeshInstance3D)
		if current_node is ScTower_PartRenderer:
			var vi := current_node as ScTower_PartRenderer
			var local_aabb := vi.get_aabb()

			# Ignore empty AABBs
			if local_aabb.size == Vector3.ZERO:
				continue

			# Convert the AABB to global world space
			var global_aabb := vi.global_transform * local_aabb

			if first_box:
				total_aabb = global_aabb
				first_box = false
			else:
				total_aabb = total_aabb.merge(global_aabb)

	return total_aabb


func _physics_process(delta: float) -> void:
	if _score_overlay != null:
		var aabb_rect := Helper.get_screen_rect(get_aabb())
		_score_overlay.rotation = -0.025
		_score_overlay.position = (
			_score_overlay
			. position
			. lerp(
				Vector2(
					minf(
						aabb_rect.end.x,
						get_viewport().get_visible_rect().end.x - _score_overlay.size.x,
					),
					clampf(
						aabb_rect.position.y - (_score_overlay.size.y * .8),
						0,
						get_viewport().get_visible_rect().end.y - _score_overlay.size.y,
					),
				),
				delta * 10.,
			)
		)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("DBG-Spawn"):
		_on_spawn()
	if _active_renderer.state == ScTower_PartRenderer.State.WAVE && Input.is_action_just_pressed("Finish"):
		_on_finish()


func _on_finish() -> void:
	if _state.close_cooldown > 0:
		var xtoclose_overlay: UiXToClose = _loader.get_resource(XTOCLOSE_SCN).instantiate()
		xtoclose_overlay.count = _state.close_cooldown
		xtoclose_overlay.offset_transform_enabled = true
		xtoclose_overlay.offset_transform_scale = Vector2.ONE * .5
		xtoclose_overlay.offset_transform_position.y = 20

		var aabb_rect := Helper.get_screen_rect(_active_renderer.get_aabb())
		xtoclose_overlay.position = Vector2(aabb_rect.position.x + (aabb_rect.size.x / 2), aabb_rect.position.y + (aabb_rect.size.y / 2))

		var tween := create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CIRC)

		add_child(xtoclose_overlay)

		tween.tween_property(xtoclose_overlay, "offset_transform_position:y", -100, 2.5)
		tween.parallel().tween_property(xtoclose_overlay, "offset_transform_scale", Vector2.ONE, .25)
		tween.parallel().tween_property(xtoclose_overlay, "modulate:a", 0, .5).set_delay(2)
		tween.parallel().tween_property(xtoclose_overlay, "offset_transform_rotation", randf_range(-.1, .1), 2.5)
		tween.finished.connect(
			func() -> void:
				if xtoclose_overlay != null:
					xtoclose_overlay.queue_free()
		)
		return
	#TODO check if can finish
	swap_part(parts_scn.get_crown())


func swap_part(part: RsPart) -> void:
	if !_active_renderer:
		return
	_active_renderer.destroy()
	_spawn_part(part)


func _on_spawn() -> void:
	var part := parts_scn.get_random_part(_state) if _state.stack_length > 0 else parts_scn.get_heel()
	_spawn_part(part)
	_render_prompts()
	_DBG_list_parts()


func _on_stack(is_success: bool, part: RsPart) -> void:
	if !is_success:
		on_game_over.emit(false, _state)
		return

	var ticker := _state.push(part, _active_renderer._rb.position.y)
	if part.is_crown:
		on_game_over.emit(true, _state)
		return

	_difficulty_numbers.on_successful_stack()
	for line in ticker:
		_score_overlay.push(line.title, line.value)
		_score_overlay.get_big_number().set_score(_state.current_session_score)
	_score_overlay.time = _difficulty_numbers.wave_speed_timer_speed
	_score_overlay.sway = _difficulty_numbers.wave_max_offset
	_on_spawn()


func _spawn_part(new_part: RsPart) -> void:
	_active_renderer = ($PartRenderer).duplicate() as ScTower_PartRenderer
	_active_renderer.was_stacked.connect(_on_stack)
	_active_renderer.part = new_part
	_active_renderer.tower_state = _state
	_active_renderer.difficulty_numbers = _difficulty_numbers
	_active_renderer.floor_collider = floor_collider
	%Stack.add_child(_active_renderer)
	Camera.GAMEPLAY_target = _active_renderer._rb


func _render_prompts() -> void:
	var prompts := %ButtonPrompts as UiButtonPrompts

	if CurrentRun.player_data.needs_tutorial == false and _state.stack_length == 0:
		prompts.push("Drop")
		prompts.push("Rotate-R")
		prompts.push("Zoom-out")
		prompts.push("Finish")
	elif CurrentRun.player_data.needs_tutorial == true:
		match _state.stack_length:
			0:
				prompts.push_tutorial("Drop")
			3:
				prompts.push_tutorial("Rotate-R")
			4:
				prompts.push_tutorial("Zoom-out")
			Helper.MIN_TO_CLOSE - 1:
				CurrentRun.player_data.needs_tutorial = false
				prompts.push_tutorial("Finish")


func _update_paper_color() -> void:
	var plate: MeshInstance3D = %PaperPlate.get_child(0) as MeshInstance3D
	if not plate:
		return

	var mat := plate.mesh.surface_get_material(0)
	if not mat:
		return

	match mode:
		ScTower.Mode.Vegan:
			mat.set("shader_parameter/base_color", Color("#00ce1b"))
			mat.set("shader_parameter/flip", true)
		ScTower.Mode.Chicken:
			mat.set("shader_parameter/base_color", Color("#f5cc00"))
			mat.set("shader_parameter/flip", true)
		_:
			mat.set("shader_parameter/base_color", Color.WHITE)
			mat.set("shader_parameter/flip", false)
	pass


func _DBG_set_up() -> void:
	if Cheats == null:
		return
	Cheats.with_container(
		"tower",
		func(container: Container) -> void:
			var btn := Button.new()
			btn.text = "Win"
			btn.pressed.connect(_DBG_on_win_pressed)
			container.add_child(btn)
	)


func _DBG_list_parts() -> void:
	if Cheats == null:
		return
	Cheats.with_container(
		"parts",
		func(container: Container) -> void:
			var available := parts_scn.get_all_parts(_state)
			for part in parts_scn.ALL_PARTS:
				var btn := Button.new()
				btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
				btn.text = ("✅" if available.has(part) else "😡") + " " + part.name
				btn.pressed.connect(func() -> void: swap_part(part))
				container.add_child(btn)
	)


func _notification(what: int) -> void:
	var prompts := get_node_or_null("%ButtonPrompts") as Control
	if prompts == null:
		return
	if what == Node.NOTIFICATION_PAUSED:
		prompts.hide()
	elif what == Node.NOTIFICATION_UNPAUSED:
		prompts.show()


func _DBG_on_win_pressed() -> void:
	_state.push(parts_scn.get_random_part(_state), 1.)
	_state.push(parts_scn.get_random_part(_state), 1.)
	_state.push(parts_scn.get_random_part(_state), 1.)
	_state.push(parts_scn.get_random_part(_state), 1.)
	_state.push(parts_scn.get_random_part(_state), 1.)
	_state.push(parts_scn.get_random_part(_state), 1.)
	_state.push(parts_scn.get_random_part(_state), 1.)
	_state.push(parts_scn.get_random_part(_state), 1.)
	on_game_over.emit(true, _state)

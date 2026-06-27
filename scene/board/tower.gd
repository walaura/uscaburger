class_name Scene_Tower
extends Node3D

@export var floor_collider: StaticBody3D

static var SCORE_OVERLAY_SCN := preload("res://ui/score_overlay.tscn")
static var PARTS_SCN := preload("uid://dn80kasyurhbx")

signal on_new_spawn(part: Variant)
signal on_game_over(did_finish: bool, score_handler: Scene_Tower_ScoreHandler)

var parts_scn: Data_Parts = PARTS_SCN.instantiate()

var mode := Mode.Normal

var part: Droppable

var _stack_height := 0.0
var _stack_length := 0

var _score_handler: Scene_Tower_ScoreHandler
var _score_overlay: UI_ScoreOverlay
@onready var _difficulty_numbers := DifficultyNumbersResource.new(mode)

enum Mode { Normal, Vegan, Chicken }


func setup(nw_mode: Mode) -> void:
	self.mode = nw_mode


func get_scene_aabb() -> AABB:
	var total_aabb: AABB
	var first_box := true

	# Helper array to process nodes iteratively to avoid recursion limits
	var nodes_to_process: Array[Node] = %Stack.get_children()
	nodes_to_process.pop_back()
	while nodes_to_process.size() > 0:
		var current_node: Node = nodes_to_process.pop_back()

		# Check if the current node is a VisualInstance (like MeshInstance3D)
		if current_node is Droppable:
			var vi := current_node as Droppable
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


func _ready() -> void:
	_on_spawn()

	_score_overlay = SCORE_OVERLAY_SCN.instantiate() as UI_ScoreOverlay
	_score_overlay.setup(mode)
	_score_handler = Scene_Tower_ScoreHandler.new(mode)
	add_child(_score_overlay)

	parts_scn.position.y = 9999999.
	parts_scn.visible = false
	add_child(parts_scn)

	_update_paper_color()
	_DBG_set_up()

	on_game_over.connect(
		func(_is_success: bool, _sh: Scene_Tower_ScoreHandler) -> void:
			remove_child($ButtonPrompts)
			if _score_overlay != null && _score_overlay.get_parent() != null:
				_score_overlay.get_parent().remove_child(_score_overlay)
	)


func _physics_process(delta: float) -> void:
	var aabb_rect := Helper.get_screen_rect(get_scene_aabb())
	_score_overlay.rotation = -0.025
	_score_overlay.position = (
			_score_overlay
			.position
			.lerp(
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
	if part.state == Droppable.State.WAVE && Input.is_action_just_pressed("Finish"):
		_on_finish()


func _on_finish() -> void:
	if !part:
		return
	part.destroy()
	_spawn_part(parts_scn.get_crown())


func _on_spawn() -> void:
	part = parts_scn.get_random_part(_score_handler) if _stack_length > 0 else parts_scn.get_heel()
	_spawn_part(part)
	_render_prompts()


func _on_stack(is_success: bool, droppable: Droppable) -> void:
	if !is_success:
		on_game_over.emit(false, _score_handler)
	elif droppable.is_crown:
		on_game_over.emit(true, _score_handler)
	else:
		_difficulty_numbers.on_successful_stack()
		var ticker := _score_handler.push(droppable, _stack_height)

		for line in ticker:
			_score_overlay.push(line.title, line.value)
			_score_overlay.get_big_number().set_score(_score_handler.current_session_score)
		_score_overlay.time = _difficulty_numbers.wave_speed_timer_speed
		_score_overlay.sway = _difficulty_numbers.wave_max_offset
		_stack_length += 1
		if droppable._rb.position.y > _stack_height:
			_stack_height = droppable._rb.position.y
		_on_spawn()


func _spawn_part(new_part: Droppable) -> void:
	new_part.setup(floor_collider, int(_stack_height), _difficulty_numbers)
	new_part.was_stacked.connect(_on_stack)
	%Stack.add_child(new_part)
	on_new_spawn.emit(new_part)


func _render_prompts() -> void:
	var prompts := %ButtonPrompts as UI_ButtonPrompts

	if CurrentRunState.player_data.needs_tutorial == false and _stack_length == 0:
		prompts.push("Drop")
		prompts.push("Rotate-R")
		prompts.push("Zoom-out")
		prompts.push("Finish")
	elif CurrentRunState.player_data.needs_tutorial == true:
		match _stack_length:
			0:
				prompts.push_tutorial("Drop")
			3:
				prompts.push_tutorial("Rotate-R")
			4:
				prompts.push_tutorial("Zoom-out")
			6:
				CurrentRunState.player_data.needs_tutorial = false
				prompts.push_tutorial("Finish")


func _update_paper_color() -> void:
	var plate: MeshInstance3D = %PaperPlate.get_child(0) as MeshInstance3D
	if not plate:
		return

	var mat := plate.mesh.surface_get_material(0)
	if not mat:
		return

	match mode:
		Scene_Tower.Mode.Vegan:
			mat.set("shader_parameter/base_color", Color("#00ce1b"))
			mat.set("shader_parameter/flip", true)
		Scene_Tower.Mode.Chicken:
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


func _DBG_on_win_pressed() -> void:
	_score_handler.push(parts_scn.get_random_part(_score_handler), 1.)
	_score_handler.push(parts_scn.get_random_part(_score_handler), 1.)
	_score_handler.push(parts_scn.get_random_part(_score_handler), 1.)
	_score_handler.push(parts_scn.get_random_part(_score_handler), 1.)
	_score_handler.push(parts_scn.get_random_part(_score_handler), 1.)
	_score_handler.push(parts_scn.get_random_part(_score_handler), 1.)
	_score_handler.push(parts_scn.get_random_part(_score_handler), 1.)
	_score_handler.push(parts_scn.get_random_part(_score_handler), 1.)
	on_game_over.emit(true, _score_handler)

class_name Scene_Tower
extends Node3D

@export var floor_collider: StaticBody3D

static var SCORE_OVERLAY_SCN := preload("res://ui/score_overlay.tscn")
static var PARTS_SCN := preload("res://data/parts/parts.tscn")

signal on_new_spawn(part: Variant)
signal on_game_over(did_finish: bool, score_handler: Scene_Tower_ScooreHandler)
var score_overlay: UI_ScoreOverlay
var score_handler: Scene_Tower_ScooreHandler
var parts_scn: Data_Parts

var stack_height := 0.0
var stack_len := 0

var last_valid_part_in_stack: CollisionShape3D
var part: Droppable

var _difficulty_numbers := DifficultyNumbersResource.new()


func _init() -> void:
	parts_scn = PARTS_SCN.instantiate()


func _ready() -> void:
	_on_spawn()

	score_overlay = SCORE_OVERLAY_SCN.instantiate() as Control
	score_handler = Scene_Tower_ScooreHandler.new()
	score_handler.overlay_ui = score_overlay
	add_child(score_overlay)

	parts_scn.position.y = 9999999.
	parts_scn.visible = false
	add_child(parts_scn)


func _physics_process(delta: float) -> void:
	var aabb_rect := Helper.get_screen_rect(get_scene_aabb())
	score_overlay.rotation = -0.025
	score_overlay.position = (
		score_overlay
		. position
		. lerp(
			Vector2(
				minf(
					aabb_rect.end.x,
					get_viewport().get_visible_rect().end.x - score_overlay.size.x,
				),
				clampf(
					aabb_rect.position.y - (score_overlay.size.y * .8),
					0,
					get_viewport().get_visible_rect().end.y - score_overlay.size.y,
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


func _on_finish() -> void:
	if !part:
		return
	part.destroy()
	_spawn_part(parts_scn.get_crown())


func _on_spawn() -> void:
	var prompts := %ButtonPrompts as UI_ButtonPrompts
	part = parts_scn.get_random_part(score_handler) if stack_len > 0 else parts_scn.get_heel()
	_spawn_part(part)
	if CurrentRunState.player_data.needs_tutorial == false and stack_len == 0:
		prompts.push("Drop")
		prompts.push("Rotate-R")
		prompts.push("Zoom-out")
		prompts.push("Finish")
	elif CurrentRunState.player_data.needs_tutorial == true:
		match stack_len:
			0:
				prompts.push_tutorial("Drop")
			3:
				prompts.push_tutorial("Rotate-R")
			4:
				prompts.push_tutorial("Zoom-out")
			6:
				CurrentRunState.player_data.needs_tutorial = false
				prompts.push_tutorial("Finish")


func _spawn_part(new_part: Droppable) -> void:
	if part:
		last_valid_part_in_stack = part.get_collider()

	new_part.floor_collider = floor_collider
	new_part.height = int(stack_height)
	new_part.was_stacked.connect(_on_stack)
	new_part.difficulty_numbers = _difficulty_numbers
	%Stack.add_child(new_part)
	on_new_spawn.emit(new_part)


func _on_stack(is_success: bool, droppable: Droppable) -> void:
	if !is_success:
		remove_child($ButtonPrompts)
		score_overlay.get_parent().remove_child(score_overlay)
		on_game_over.emit(false, score_handler)
	elif droppable.is_crown:
		remove_child($ButtonPrompts)
		score_overlay.get_parent().remove_child(score_overlay)
		on_game_over.emit(true, score_handler)
	else:
		_difficulty_numbers.on_successful_stack()
		score_handler.push(droppable)
		score_overlay.time = _difficulty_numbers.wave_speed_timer_speed
		score_overlay.sway = _difficulty_numbers.wave_max_offset
		stack_len += 1
		if droppable._rb.position.y > stack_height:
			stack_height = droppable._rb.position.y
		_on_spawn()


func _on_win_pressed() -> void:
	score_handler.push(parts_scn.get_random_part(score_handler))
	score_handler.push(parts_scn.get_random_part(score_handler))
	score_handler.push(parts_scn.get_random_part(score_handler))
	score_handler.push(parts_scn.get_random_part(score_handler))
	score_handler.push(parts_scn.get_random_part(score_handler))
	score_handler.push(parts_scn.get_random_part(score_handler))
	score_handler.push(parts_scn.get_random_part(score_handler))
	score_handler.push(parts_scn.get_random_part(score_handler))
	on_game_over.emit(true, score_handler)

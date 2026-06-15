extends Node

class_name BurgerTower

@export var floor_collider: StaticBody3D

static var SCORE_OVERLAY_SCN = preload("res://ui/score_overlay.tscn")
static var SCORE_HANDLER_SC = preload("res://object/burger_tower/score.gd")
static var PARTS_SCN = preload("res://object/parts.tscn")
var score_overlay: Control
var score_handler: BurgerTower_ScooreHandler
var parts_scn: Parts

signal on_new_spawn(part: Variant)
signal on_game_over(did_finish: bool, score_handler: BurgerTower_ScooreHandler)
var stack_height := 0.0

var last_valid_part_in_stack: CollisionShape3D
var part: Droppable


func _init():
	parts_scn = PARTS_SCN.instantiate()


func _ready() -> void:
	_on_spawn()

	score_overlay = SCORE_OVERLAY_SCN.instantiate() as Control
	score_handler = SCORE_HANDLER_SC.new()
	score_handler.overlay_ui = score_overlay
	add_child(score_overlay)


func _physics_process(delta):
	var aabb_rect := Helper.get_screen_rect(get_scene_aabb())
	score_overlay.rotation = -0.025
	score_overlay.position = score_overlay.position.lerp(
		Vector2(
			min(aabb_rect.end.x, get_viewport().get_visible_rect().end.x - score_overlay.size.x),
			clamp(
				aabb_rect.position.y - (score_overlay.size.y * .8),
				0,
				get_viewport().get_visible_rect().end.y - score_overlay.size.y
			)
		),
		delta * 10
	)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("DBG-Spawn"):
		_on_spawn()
	if part.state == Droppable.State.WAVE && Input.is_action_just_pressed("Finish"):
		_on_finish()


func get_scene_aabb() -> AABB:
	var total_aabb: AABB
	var first_box = true

	# Helper array to process nodes iteratively to avoid recursion limits
	var nodes_to_process: Array[Node] = %Stack.get_children()
	nodes_to_process.pop_back()
	while nodes_to_process.size() > 0:
		var current_node = nodes_to_process.pop_back()

		# Check if the current node is a VisualInstance (like MeshInstance3D)
		if current_node is Droppable:
			var vi := current_node as Droppable
			var local_aabb := vi.get_aabb()

			# Ignore empty AABBs
			if local_aabb.size == Vector3.ZERO:
				continue

			# Convert the AABB to global world space
			var global_aabb = vi.global_transform * local_aabb

			if first_box:
				total_aabb = global_aabb
				first_box = false
			else:
				total_aabb = total_aabb.merge(global_aabb)

	return total_aabb


func _on_finish():
	if !part:
		return
	part.destroy()
	_spawn_part(parts_scn.get_crown())


func _on_spawn() -> void:
	part = parts_scn.get_random_part() if stack_height > 0 else parts_scn.get_heel()
	_spawn_part(part)


func _spawn_part(new_part: Droppable):
	if part:
		last_valid_part_in_stack = part.get_collider()

	new_part.floor_collider = floor_collider
	new_part.height = stack_height
	new_part.was_stacked.connect(_on_stack)
	%Stack.add_child(new_part)
	on_new_spawn.emit(new_part)


func _on_stack(is_success: bool, droppable: Droppable):
	if !is_success:
		score_overlay.get_parent().remove_child(score_overlay)
		on_game_over.emit(false, score_handler)
	elif droppable.is_crown:
		score_overlay.get_parent().remove_child(score_overlay)
		on_game_over.emit(true, score_handler)
	else:
		score_handler.push(droppable)
		if droppable._rb.position.y > stack_height:
			stack_height = droppable._rb.position.y
		_on_spawn()

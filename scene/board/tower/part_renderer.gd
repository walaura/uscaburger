class_name ScTower_PartRenderer
extends Node3D

signal was_stacked(success: bool, part: RsPart)

enum State { WAVE, DROP, DONE }

const PHYS_MATERIAL = preload("res://asset/part_phys_material.tres")

var part: RsPart

@export var floor_collider: StaticBody3D
@export var difficulty_numbers: RsDifficultyNumbers
var height := 0.0

var _drop_timer := Timer.new()
var _wave_speed_timer := Timer.new()
var _wave_speed_timer_rand_offsset := 0.0

var state := State.WAVE

var _mesh: MeshInstance3D
var _collider: CollisionShape3D
var _maybe_splat: MeshInstance3D = null
var _rb: RigidBody3D

var _did_touch_anything := false
@onready var _initial_scale := Vector3(1, Helper.ITEM_Y_SCALE, 1) * randf_range(.9, 1.1)


func setup(
	nw_floor_collider: StaticBody3D,
	nw_height: int,
	nw_difficulty_numbers: RsDifficultyNumbers,
) -> void:
	floor_collider = nw_floor_collider
	height = nw_height
	difficulty_numbers = nw_difficulty_numbers


func get_aabb() -> AABB:
	var aabb := (_mesh as VisualInstance3D).get_aabb()
	return _rb.transform * aabb


func get_collider() -> CollisionShape3D:
	return _collider


func destroy() -> void:
	_change_state(State.DONE)
	_collider.set.call_deferred("disabled", true)
	_play_splooch_out_anim().finished.connect(func() -> void: self.get_parent().remove_child(self))


func _init() -> void:
	visible = false


func _ready() -> void:
	if not can_process():
		return

	if not part:
		return

	self.transform.origin = Vector3.ZERO

	var model: Node = part.model.instantiate()
	var model_child := model.get_child(0) as RigidBody3D
	if not model_child:
		printerr("no model!!")
		return

	_rb = model_child
	for child in _rb.get_children():
		if child is CollisionShape3D:
			_collider = child
		elif child.name.begins_with("_splat"):
			_maybe_splat = child
		else:
			_mesh = child
	if _maybe_splat != null:
		_maybe_splat.hide()

	add_child(model)

	_rotate(randf())
	_rb.scale_object_local(_initial_scale)

	var mat := PHYS_MATERIAL
	var maybe_glue := CurrentRun.inventory.get_held_item_by_key("glue.tres")
	if maybe_glue != null:
		mat.friction = maybe_glue.incremental_value / 100

	_rb.continuous_cd = true
	_rb.physics_material_override = mat
	_rb.freeze = 1
	_rb.contact_monitor = true
	_rb.max_contacts_reported = 1

	_collider.shape.margin = 10.

	self.add_child(_drop_timer)
	self.add_child(_wave_speed_timer)

	_wave_speed_timer_rand_offsset = randf()
	_wave_speed_timer.start(difficulty_numbers.wave_speed_timer_speed)
	self._rb.position = Vector3(0, height + 3, 0)

	_sling_sideways()
	_play_splooch_in_anim()
	visible = true

	self._rb.body_entered.connect(_on_body_entered)
	_drop_timer.timeout.connect(_on_drop_timer_time_out)
	_drop_timer.one_shot = true


func _rotate(step: float) -> void:
	var rotate_y_by := step * PI * 2
	(_rb as Node3D).rotate_y(rotate_y_by)


func _on_body_entered(body: Node3D) -> void:
	if not _did_touch_anything:
		_did_touch_anything = true
		_play_splooch_anim()

	# sauces insta-drop
	if part.is_sauce && body != floor_collider:
		_rb.rotation = Vector3(0, rotation.y, 0)
		_change_state(State.DONE)
		was_stacked.emit(true, part)
		return

	# crown slows down time
	if part.name == ScTower_Parts.get_item("crown").name:
		Engine.time_scale = .5

	if body != floor_collider:
		return

	_change_state(State.DONE)

	# Heels can touch the floor duh
	if part.is_heel:
		was_stacked.emit(true, part)
		return
	was_stacked.emit(false, part)


func _play_splooch_out_anim() -> Tween:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUINT)

	tween.tween_property(_mesh, "scale", Vector3.ZERO, .75)
	tween.parallel().tween_property(_mesh, "position:y", .5, .75)

	return tween


func _play_splooch_in_anim() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)

	_mesh.scale = Vector3.ZERO
	_mesh.position.y = .5
	tween.tween_property(_mesh, "scale", _initial_scale, .75)
	tween.parallel().tween_property(_mesh, "position:y", 0, .75)


func _play_splooch_anim() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	if _maybe_splat == null:
		tween.tween_property(_mesh, "scale", _initial_scale * Vector3(1.25, .5, 1.25), .1)
		tween.tween_property(_mesh, "scale", _initial_scale, .4)

	else:
		_maybe_splat.scale = Vector3.ZERO
		_maybe_splat.transparency = 1.
		_maybe_splat.visible = true

		tween.tween_property(_mesh, "scale", Vector3(1.25, 0, 1.25), .25)
		tween.parallel().tween_property(_mesh, "transparency", 1., .25)
		tween.parallel().tween_property(_maybe_splat, "scale", Vector3(1.3, 1, 1.3), .1)
		tween.parallel().tween_property(_maybe_splat, "transparency", 0., .05)
		tween.tween_property(_maybe_splat, "scale", _initial_scale, .25)


func _on_drop_timer_time_out() -> void:
	_change_state(State.DONE)
	was_stacked.emit(true, part)


func _sling_sideways() -> void:
	var position_time_normal := fmod(
		(_wave_speed_timer.time_left / difficulty_numbers.wave_speed_timer_speed) + _wave_speed_timer_rand_offsset,
		1,
	)

	if position_time_normal > .5:
		position_time_normal = 1 - position_time_normal
	position_time_normal = (position_time_normal * 2)

	var posi := lerpf(
		difficulty_numbers.wave_max_offset * -1.0,
		difficulty_numbers.wave_max_offset * +1.0,
		position_time_normal,
	)
	self._rb.position.x = posi


func _is_falling() -> bool:
	return abs(_rb.get_linear_velocity().y) > 1


func _change_state(new_state: State) -> void:
	self.state = new_state
	match state:
		State.DONE:
			self._rb.freeze = 1
			Engine.time_scale = 1.
			_drop_timer.stop()


func _get_drop_timeout() -> float:
	if part.name == ScTower_Parts.get_item("crown").name:
		return difficulty_numbers.drop_timeout / 2
	else:
		return difficulty_numbers.drop_timeout


func _process(delta: float) -> void:
	if not part:
		return
	match state:
		State.WAVE:
			_sling_sideways()
			if Input.is_action_just_pressed("Drop"):
				_change_state(State.DROP)
			if Input.is_action_pressed("Rotate-R"):
				_rotate(-.4 * delta)
			if Input.is_action_pressed("Rotate-L"):
				_rotate(.4 * delta)
		State.DROP:
			self._rb.freeze = false

			if _drop_timer.is_stopped() && !_is_falling():
				_drop_timer.start(_get_drop_timeout())

			if !_drop_timer.is_stopped() && _is_falling():
				_drop_timer.start(_get_drop_timeout())

			if _did_touch_anything:
				Camera.GAMEPLAY_dramatic_timer_zoom = _drop_timer.time_left / _get_drop_timeout()

	# dramatic zoom
	if _drop_timer.is_stopped():
		Camera.GAMEPLAY_dramatic_timer_zoom = 1.

class_name Droppable
extends Node3D

signal was_stacked(success: bool, height: float)

enum State { WAVE, DROP, DONE }

const PHYS_MATERIAL = preload("res://asset/part_phys_material.tres")

@export var price: int
@export var receipt_name: String
@export var is_heel := false
@export var is_crown := false
@export var is_sauce := false

var floor_collider: StaticBody3D
var height := 0
var state := State.WAVE
var difficulty_numbers: DifficultyNumbersResource

var _drop_timer := Timer.new()
var _wave_speed_timer := Timer.new()
var _wave_speed_timer_rand_offsset := 0.0

var _internal_animatable := Animatable.new()
var _mesh: MeshInstance3D
var _collider: CollisionShape3D
var _maybe_splat: MeshInstance3D = null
var _rb: RigidBody3D

var _has_splooched := false
var _initial_scale := Vector3.ONE


func set_initial_size() -> void:
	var rng := RandomNumberGenerator.new()
	_initial_scale = Vector3(1, Helper.ITEM_Y_SCALE, 1) * rng.randf_range(.9, 1.1)
	_rotate(rng.randf())
	_internal_animatable.scale_object_local(_initial_scale)
	(get_child(0).get_child(1) as Node3D).scale_object_local(_initial_scale)
	return


func get_aabb() -> AABB:
	var aabb := (_mesh as VisualInstance3D).get_aabb()
	return _rb.transform * aabb


func get_collider() -> CollisionShape3D:
	return _collider


func destroy() -> void:
	_change_state(State.DONE)
	_internal_animatable.player.animation_finished.connect(
		func(_p: Variant) -> void: self.get_parent().remove_child(self)
	)
	_internal_animatable.player.play("animations/pop", -1, -2, true)


func _init() -> void:
	visible = false


func _ready() -> void:
	if not can_process():
		return

	self.transform.origin = Vector3.ZERO
	set_initial_size()

	_rb = get_child(0)
	for child in _rb.get_children():
		if child is CollisionShape3D:
			_collider = child
		elif child.name.begins_with("_splat"):
			_maybe_splat = child
		else:
			_mesh = child
	if _maybe_splat != null:
		_maybe_splat.hide()

	_rb.remove_child(_mesh)
	_internal_animatable.add_child(_mesh)
	_rb.add_child(_internal_animatable)

	_rb.continuous_cd = true
	_rb.physics_material_override = PHYS_MATERIAL
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

	_internal_animatable.play("animations/pop")
	visible = true

	self._rb.body_entered.connect(_on_body_entered)
	_drop_timer.timeout.connect(_on_drop_timer_time_out)
	_drop_timer.one_shot = true


func _rotate(step: float) -> void:
	var rotate_y_by := step * PI * 2

	_internal_animatable.rotate_y(rotate_y_by)
	(get_child(0).get_child(1) as Node3D).rotate_y(rotate_y_by)


func _on_body_entered(body: Node3D) -> void:
	if not _has_splooched:
		_has_splooched = true
		_play_splooch_anim()

	# sauces insta-drop
	if is_sauce && body != floor_collider:
		_rb.rotation = Vector3(0, rotation.y, 0)
		_change_state(State.DONE)
		was_stacked.emit(true, self)
		return

	if body != floor_collider:
		return

	_change_state(State.DONE)
	# Heels can touch the floor duh
	if is_heel:
		was_stacked.emit(true, self)
		return
	was_stacked.emit(false, self)


func _play_splooch_anim() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)

	if _maybe_splat == null:
		tween.set_trans(Tween.TRANS_BOUNCE)
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
	was_stacked.emit(true, self)


func _sling_sideways() -> void:
	var position_time_normal := fmod(
		(
			(_wave_speed_timer.time_left / difficulty_numbers.wave_speed_timer_speed)
			+ _wave_speed_timer_rand_offsset
		),
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
			_drop_timer.stop()


func _process(delta: float) -> void:
	match state:
		State.WAVE:
			_sling_sideways()
			if Input.is_action_just_pressed("Drop"):
				_change_state(State.DROP)
			if Input.is_action_pressed("Rotate-R"):
				_rotate(-.1 * delta)
			if Input.is_action_pressed("Rotate-L"):
				_rotate(.1 * delta)
		State.DROP:
			self._rb.freeze = false

			if _drop_timer.is_stopped() && !_is_falling():
				_drop_timer.start(difficulty_numbers.drop_timeout)

			if !_drop_timer.is_stopped() && _is_falling():
				_drop_timer.start(difficulty_numbers.drop_timeout)

	# dramatic zoom
	Camera.GAMEPLAY_dramatic_timer_zoom = _drop_timer.time_left / difficulty_numbers.drop_timeout

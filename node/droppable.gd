class_name Droppable extends Node3D

const PHYS_MATERIAL = preload("res://asset/part_phys_material.tres")

@export var price: int
@export var receipt_name: String
@export var is_heel := false
@export var is_crown := false

@export_group("Hidden stuffs lol")
@export var floor_collider: StaticBody3D
@export var height := 0

enum State { WAVE, DROP, DONE }
var state := State.WAVE

signal was_stacked(success: bool, height: float)

var drop_timer := Timer.new()
var wave_speed_timer := Timer.new()
var wave_speed_timer_rand_offsset := 0.0

var _internal_animatable := Animatable.new()
var _mesh: MeshInstance3D
var _collider: CollisionShape3D
var _rb: RigidBody3D

var _has_splooched := false


func set_initial_size() -> void:
	var rng := RandomNumberGenerator.new()
	var initial_scale := Vector3(1, Helper.ITEM_Y_SCALE, 1) * rng.randf_range(.9, 1.1)
	_rotate(rng.randf())
	_internal_animatable.scale_object_local(initial_scale)
	(get_child(0).get_child(1) as Node3D).scale_object_local(initial_scale)
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
	self.transform.origin = Vector3.ZERO
	set_initial_size()

	_rb = get_child(0)
	_mesh = _rb.get_child(0)
	_collider = _rb.get_child(1)

	_rb.remove_child(_mesh)
	_internal_animatable.add_child(_mesh)
	_rb.add_child(_internal_animatable)

	_rb.continuous_cd = true
	_rb.physics_material_override = PHYS_MATERIAL
	_rb.freeze = 1
	_rb.contact_monitor = true
	_rb.max_contacts_reported = 1

	_collider.shape.margin = 10.

	self.add_child(drop_timer)
	self.add_child(wave_speed_timer)

	wave_speed_timer_rand_offsset = randf()
	wave_speed_timer.start(Helper.WAVE_SPEED_TIMER_SPEED)
	self._rb.position = Vector3(0, height + 3, 0)
	_sling_sideways()

	_internal_animatable.play("animations/pop")
	visible = true

	self._rb.body_entered.connect(_on_body_entered)
	drop_timer.timeout.connect(_on_drop_timer_time_out)
	drop_timer.one_shot = true


func _rotate(step: float) -> void:
	var rotate_y_by := step * PI * 2

	_internal_animatable.rotate_y(rotate_y_by)
	(get_child(0).get_child(1) as Node3D).rotate_y(rotate_y_by)


func _on_body_entered(body: Node3D) -> void:
	if not _has_splooched:
		_internal_animatable.player.play("animations/splooch", -1, 2)
		_has_splooched = true
	if body != floor_collider:
		return

	_change_state(State.DONE)
	# Heels can touch the floor duh
	if is_heel:
		was_stacked.emit(true, self)
		return
	was_stacked.emit(false, self)


func _on_drop_timer_time_out() -> void:
	_change_state(State.DONE)
	was_stacked.emit(true, self)


func _sling_sideways() -> void:
	var position_time_normal := fmod(
		(
			(wave_speed_timer.time_left / Helper.WAVE_SPEED_TIMER_SPEED)
			+ wave_speed_timer_rand_offsset
		),
		1
	)

	if position_time_normal > .5:
		position_time_normal = 1 - position_time_normal
	position_time_normal = (position_time_normal * 2)

	var posi := lerpf(
		Helper.WAVE_MAX_OFFSET * -1.0, Helper.WAVE_MAX_OFFSET * +1.0, position_time_normal
	)
	self._rb.position.x = posi


func _is_falling() -> bool:
	return abs(_rb.get_linear_velocity().y) > 1


func _change_state(new_state: State) -> void:
	self.state = new_state
	match state:
		State.DONE:
			self._rb.freeze = 1
			drop_timer.stop()


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

			if drop_timer.is_stopped() && !_is_falling():
				drop_timer.start(Helper.DROP_TIMEOUT)

			if !drop_timer.is_stopped() && _is_falling():
				drop_timer.start(Helper.DROP_TIMEOUT)

	# dramatic zoom
	Camera.GAMEPLAY_dramatic_timer_zoom = drop_timer.time_left / Helper.DROP_TIMEOUT

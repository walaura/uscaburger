class_name UiKetchupBadgeWStamp
extends Control

const BADGE_SLOP := 8.

@export var is_sloppy := true
@export var badge: Control
var _hover_tween: Tween
var _rota_tween: Tween


func _draw() -> void:
	if !badge:
		return
	badge.custom_maximum_size = size
	badge.custom_minimum_size = size
	badge.set_anchors_and_offsets_preset(LayoutPreset.PRESET_FULL_RECT)
	badge.pivot_offset_ratio = Vector2.ONE / 2


func _ready() -> void:
	if !badge:
		print("nonono")
		return

	var placeholder := $Badge
	if badge.get_parent():
		badge.get_parent().remove_child.call_deferred(badge)
	add_child.call_deferred(badge)
	placeholder.queue_free()

	badge.position = Vector2.ZERO
	badge.visible = true

	var rng := RandomNumberGenerator.new()
	badge.offset_transform_enabled = true
	badge.offset_transform_position = Vector2(
		rng.randf_range(BADGE_SLOP * -1, BADGE_SLOP),
		rng.randf_range(BADGE_SLOP * -1, BADGE_SLOP),
	)
	placeholder.free.call_deferred()


func _setup_tweens() -> void:
	if _hover_tween != null:
		_hover_tween.kill()
	if _rota_tween != null:
		_rota_tween.kill()
	_hover_tween = create_tween()
	_hover_tween.set_loops(0)
	_hover_tween.set_trans(Tween.TRANS_CIRC)
	_hover_tween.set_ease(Tween.EASE_OUT)


func _on_mouse_entered() -> void:
	_setup_tweens()
	_hover_tween.tween_property($HoverRect as Control, "offset_transform_scale", Vector2.ONE * 1.1, .2)
	_hover_tween.parallel().tween_property($HoverRect/TextureRect as Control, "modulate:a", 1, .1)
	_hover_tween.parallel().tween_property($HoverRect as Control, "offset_transform_rotation", 0, .2)
	_hover_tween.parallel().tween_property(badge, "scale", Vector2.ONE * 1.1, .25)
	if badge is UiKetchupBadge:
		_hover_tween.parallel().tween_property(badge, "edge", .5, .25)

	_rota_tween = create_tween()
	_rota_tween.set_loops()
	_rota_tween.tween_property($HoverRect/TextureRect as Control, "offset_transform_rotation", PI, 3.).from(0.)


func _on_mouse_exited() -> void:
	_setup_tweens()
	_hover_tween.tween_property($HoverRect as Control, "offset_transform_scale", Vector2.ONE * .1, 1.)
	_hover_tween.parallel().tween_property($HoverRect as Control, "offset_transform_rotation", -2., 1.)
	_hover_tween.parallel().tween_property(badge, "scale", Vector2.ONE, .25)
	_hover_tween.parallel().tween_property($HoverRect/TextureRect as Control, "modulate:a", 0, .2)
	if badge is UiKetchupBadge:
		_hover_tween.parallel().tween_property(badge, "edge", 0., 1)

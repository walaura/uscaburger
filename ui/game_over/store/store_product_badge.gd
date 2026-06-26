class_name UI_GameOver_StoreProductBadge
extends Control

@export var icon: Texture2D:
	set(val):
		icon = val
		if is_node_ready():
			_draw_ui()

@export var edge: float:
	set(val):
		edge = val
		(get_node("%Badge") as ColorRect).material.set("shader_parameter/Edge", edge)


func _ready() -> void:
	if !icon:
		return
	_draw_ui()


func _draw_ui() -> void:
	var badge_node := get_node("%Badge") as ColorRect
	var rng := RandomNumberGenerator.new()

	badge_node.material.set("shader_parameter/Badge", icon)
	badge_node.material.set("shader_parameter/RotaForEdge", rng.randf())
	badge_node.material.set("shader_parameter/Rota", rng.randf())


func animate() -> void:
	var badge_node := get_node("%Badge") as ColorRect
	var rng := RandomNumberGenerator.new()

	badge_node.material.set("shader_parameter/Edge", rng.randf_range(.2, 1))
	badge_node.pivot_offset_ratio = Vector2.ONE / 2

	var tween := create_tween()
	tween.tween_property(badge_node.material, "shader_parameter/Edge", 0.0, .4)
	(
		tween
		. parallel()
		. tween_property(badge_node, "scale", Vector2.ONE, .25)
		. from(Vector2.ONE * 1.2)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)


func _process(_delta: float) -> void:
	var badge_node := get_node("%Badge") as ColorRect

	if badge_node != null:
		(
			badge_node
			. material
			. set(
				"shader_parameter/Gloss",
				get_viewport().get_mouse_position().x / get_viewport().get_visible_rect().size.x,
			)
		)
		(
			badge_node
			. material
			. set(
				"shader_parameter/RotaForGloss",
				get_viewport().get_mouse_position().y / get_viewport().get_visible_rect().size.y,
			)
		)

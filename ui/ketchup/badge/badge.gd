class_name UiKetchupBadge
extends Control

@export var icon: Texture2D:
	set(val):
		icon = val
		queue_redraw()
@export var edge: float:
	set(val):
		edge = val
		(get_node("%Badge") as ColorRect).material.set("shader_parameter/Edge", edge)
@export var animates := true
@export var tier: int = 0

@export var is_new: bool = false
@export var is_never_purchased: bool = false


func _draw() -> void:
	if !is_node_ready():
		await ready
	var badge_node := %Badge as ColorRect
	badge_node.material.set("shader_parameter/Badge", icon)

	if tier > 1:
		(%TierWrapper as Control).show()
		(%TierLabel as Label).text = str(tier)

	if is_new or is_never_purchased:
		(%NewWrapper as UIKetchupMiniBadge).show()
		(%NewWrapper as UIKetchupMiniBadge).greyscale = !is_new


func _ready() -> void:
	(%Badge as ColorRect).material.set("shader_parameter/RotaForEdge", randf())
	(%Badge as ColorRect).material.set("shader_parameter/Rota", randf())

	_ready_animation()
	if animates:
		animate_in()


func _ready_animation() -> void:
	var badge_node := get_node("%Badge") as ColorRect
	var rng := RandomNumberGenerator.new()

	badge_node.material.set("shader_parameter/Edge", rng.randf_range(.2, 1))
	badge_node.material.set("shader_parameter/Alpha", 0)
	badge_node.pivot_offset_ratio = Vector2.ONE / 2


func animate_in() -> void:
	var badge_node := get_node("%Badge") as ColorRect
	var tween := create_tween()
	tween.tween_property(badge_node.material, "shader_parameter/Edge", 0.0, .6)
	tween.parallel().tween_property(badge_node.material, "shader_parameter/Alpha", 1, .1)
	tween.parallel().tween_property(badge_node, "scale", Vector2.ONE, 1).from(Vector2.ONE * 1.2).set_trans(Tween.TRANS_SINE).set_ease(
		Tween.EASE_OUT
	)


func _process(_delta: float) -> void:
	var badge_node := get_node("%Badge") as ColorRect

	if badge_node != null:
		badge_node.material.set("shader_parameter/Gloss", get_viewport().get_mouse_position().x / get_viewport().get_visible_rect().size.x)
		badge_node.material.set(
			"shader_parameter/RotaForGloss", get_viewport().get_mouse_position().y / get_viewport().get_visible_rect().size.y
		)

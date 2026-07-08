class_name TweenHelper

@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
static func maybe_init(node: Node, tween: Tween, ease_type: Tween.EaseType = -1, trans_type: Tween.TransitionType = Tween.TRANS_CUBIC) -> Tween:
	if tween == null:
		tween = node.create_tween()
	if not tween.is_valid():
		tween = node.create_tween()

	if ease_type > 0:
		tween.set_ease(ease_type)
		tween.set_trans(trans_type)

	return tween


static func wire_skip(tween: Tween, input_event: InputEvent) -> void:
	if tween != null && input_event.is_action("UI_Skip"):
		tween.set_speed_scale(10.0)

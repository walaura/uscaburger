@tool
class_name UiKetchup_Button
extends Button

var _rota_tween: Tween
var _hover_tween: Tween
var _loop_tween: Tween

const ROTATE_FOR := -.075

@export var is_small := false:
	set(value):
		is_small = value
		if not is_node_ready():
			await ready
		_redraw_ui()


func _notification(what: int) -> void:
	if not Engine.is_editor_hint():
		return
	if what == 30:
		_redraw_ui()


func _redraw_ui() -> void:
	theme_type_variation = "ButtonFakeSmall" if is_small else "ButtonFake"
	var label := $CenterContainer/Label as Label
	if label:
		label.text = text
		label.theme_type_variation = "ButtonLabelSmall" if is_small == true else "ButtonLabel"


func _ready() -> void:
	_redraw_ui()


func _setup_tweens() -> void:
	if _hover_tween != null:
		_hover_tween.kill()
	if _rota_tween != null:
		_rota_tween.kill()
	if _loop_tween != null:
		_loop_tween.kill()
	_hover_tween = create_tween()
	_hover_tween.set_loops(0)
	_hover_tween.set_trans(Tween.TRANS_BACK)
	_hover_tween.set_ease(Tween.EASE_OUT)


func _on_mouse_entered() -> void:
	_setup_tweens()
	_hover_tween.tween_property((%Hover as ColorRect).material, "shader_parameter/FadeIn", 1., .3)
	_hover_tween.parallel().tween_property((%HoverShadow as ColorRect).material, "shader_parameter/FadeIn", 1., .3)
	_hover_tween.parallel().tween_property(self, "offset_transform_scale", Vector2.ONE * 1.025, .1)
	_hover_tween.parallel().tween_property(%Label, "offset_transform_scale", Vector2.ONE * 1.1, .125)

	_rota_tween = create_tween()
	_rota_tween.set_loops()
	_rota_tween.tween_property(%Label, "offset_transform_rotation", ROTATE_FOR * -1, .5).from(ROTATE_FOR)
	_rota_tween.tween_property(%Label, "offset_transform_rotation", ROTATE_FOR, .5)

	_loop_tween = create_tween()
	_loop_tween.tween_property((%Hover as ColorRect).material, "shader_parameter/HoverScroll", -30., 60. * 5)


func _on_mouse_exited() -> void:
	_setup_tweens()

	_hover_tween.tween_property((%Hover as ColorRect).material, "shader_parameter/FadeIn", 0, .3)
	_hover_tween.parallel().tween_property((%HoverShadow as ColorRect).material, "shader_parameter/FadeIn", 0, .3)
	_hover_tween.parallel().tween_property(%Label, "offset_transform_scale", Vector2.ONE, .125)
	_hover_tween.parallel().tween_property((%Hover as ColorRect).material, "shader_parameter/HoverScroll", 0, .2)
	_hover_tween.parallel().tween_property(%Label, "offset_transform_rotation", 0., 1)
	_hover_tween.parallel().tween_property(self, "offset_transform_scale", Vector2.ONE, .25)


func _on_button_down() -> void:
	_setup_tweens()

	_hover_tween.parallel().tween_property(%Label, "offset_transform_scale", Vector2.ONE * .9, .125)
	_hover_tween.parallel().tween_property(self, "offset_transform_scale", Vector2.ONE * .9, .25)


func _on_focus_entered() -> void:
	if Helper.is_joypad:
		_on_mouse_entered()
	else:
		_setup_tweens()
		_hover_tween.parallel().tween_property((%Rest as ColorRect).material, "shader_parameter/Opacity", .4, .2)
		_hover_tween.parallel().tween_property(%Label, "offset_transform_scale", Vector2.ONE * 1.1, .125)


func _on_focus_exited() -> void:
	if Helper.is_joypad:
		_on_mouse_exited()
	else:
		_setup_tweens()
		_hover_tween.parallel().tween_property((%Rest as ColorRect).material, "shader_parameter/Opacity", .8, .2)
		_hover_tween.parallel().tween_property(%Label, "offset_transform_scale", Vector2.ONE, .125)

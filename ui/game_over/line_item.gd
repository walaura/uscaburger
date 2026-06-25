@tool
class_name UI_GameOver_LineItem
extends HBoxContainer

enum Style { TOT, LINE, EMPTY, CENTER, HONKING }

@export var anim_length := 1.
@export var style := Style.TOT:
	set(val):
		style = val
		_draw_ui()

var _score := 0
var _display_score := 0

@export var deets := "-":
	set(val):
		deets = val
		_draw_ui()


func _ready() -> void:
	_draw_ui()


func _draw_ui() -> void:
	if has_node("%Price") == false:
		return

	match style:
		Style.LINE:
			(%Deets as Label).text = "-----------------------------------"
			(%Price as Label).hide()
		Style.CENTER:
			(%Deets as Label).text = deets
			(%Deets as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			(%Price as Label).hide()
		Style.EMPTY:
			(%Deets as Label).text = " "
			(%Price as Label).hide()
		Style.TOT, Style.HONKING:
			(%Deets as Label).text = deets
			(%Price as Label).show()

	if style == Style.HONKING:
		(%Price as Label).add_theme_color_override("font_color", Helper.COLOR_RED)
		(%Deets as Label).add_theme_color_override("font_color", Helper.COLOR_RED)
	else:
		(%Price as Label).remove_theme_color_override("font_color")
		(%Deets as Label).remove_theme_color_override("font_color")


func set_score(val: int) -> void:
	_score = val
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "_display_score", _score, anim_length)

	var scaler_tween := create_tween()
	(%Price as Label).offset_transform_rotation = -.2
	(%Price as Label).offset_transform_scale = Vector2.ONE * 1.5

	var tease_anim_length := anim_length / 100 * 90

	(
		scaler_tween
		. tween_property(
			%Price as Label,
			"offset_transform_rotation",
			-.15,
			tease_anim_length,
		)
	)
	(
		scaler_tween
		. parallel()
		. tween_property(
			%Price as Label,
			"offset_transform_scale",
			Vector2.ONE * 1.3,
			tease_anim_length,
		)
	)

	(
		scaler_tween
		. tween_property(
			%Price as Label,
			"offset_transform_rotation",
			0.,
			anim_length - tease_anim_length,
		)
	)
	(
		scaler_tween
		. parallel()
		. tween_property(
			%Price as Label,
			"offset_transform_scale",
			Vector2.ONE * 1.,
			anim_length - tease_anim_length,
		)
	)


func _process(_delta: float) -> void:
	if has_node("%Price") == false:
		return
	if Engine.is_editor_hint():
		return
	(get_node("%Price") as Label).text = Helper.format_currency(_display_score)
	pass

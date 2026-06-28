class_name UI_GameOver_ScoresTkt
extends VBoxContainer

var _tween: Tween


func play_intro(ticker: Array[CurrentRunState_ScoreLineItemResource]) -> Tween:
	_tween = create_tween()
	print(ticker)
	for line in ticker:
		_tween = push_ticket_line(line)
	return _tween


func _input(event: InputEvent) -> void:
	if _tween != null && event.is_action("UI_Skip"):
		_tween.set_speed_scale(10.0)


func push_ticket_line(
		line: CurrentRunState_ScoreLineItemResource,
) -> Tween:
	var tkt_line: UI_GameOver_LineItem = (
			($LineItem as InstancePlaceholder).create_instance().duplicate()
	)

	if not _tween.is_valid():
		_tween = create_tween()

	if line is CurrentRunState_ScoreLineItemNullResource:
		return _tween

	tkt_line.visible = true

	if line is CurrentRunState_ScoreLineItemDividerResource:
		tkt_line.style = tkt_line.Style.LINE
	elif line is CurrentRunState_ScoreLineItemBrResource:
		tkt_line.style = tkt_line.Style.EMPTY
	else:
		tkt_line.deets = line.explanation
	if line.is_total:
		tkt_line.style = tkt_line.Style.HONKING

	tkt_line.scale = Vector2(2, 2)
	tkt_line.anim_length = .5
	tkt_line.modulate = Color.TRANSPARENT
	tkt_line.pivot_offset = Vector2.ONE / 2
	add_child(tkt_line)

	(
			_tween
			.tween_property(tkt_line, "scale", Vector2.ONE, .15 * Helper.anim_speed)
			.from(
				Vector2.ONE * 1.1,
			)
	)

	_tween.parallel().tween_property(tkt_line, "modulate:a", 1, 0.2 * Helper.anim_speed)
	if line is not CurrentRunState_ScoreLineItemDividerResource:
		_tween.parallel().tween_callback(func() -> void: tkt_line.set_score(line.value))
		_tween.tween_property(tkt_line, "modulate:a", 1, .5 * Helper.anim_speed)

	return _tween

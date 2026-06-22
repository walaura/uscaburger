extends Control

class_name UI_ScoreOverlay


func push(line_item: String, value: int) -> void:
	push_ticker_line(line_item, value)
	(%BigNumber as UI_ScoreOverlayBigNumber).add_to_score(value)


func push_ticker_line(line_item: String, value: int) -> void:
	(%BigNumber.get_parent() as CanvasItem).show()
	var label := %TickerItem.duplicate() as UI_ScoreOverlayTickerItem
	%Receipt.add_child(label)
	label.push(line_item, value)


func get_big_number() -> UI_ScoreOverlayBigNumber:
	return %BigNumber


func _ready() -> void:
	(%BigNumber.get_parent() as CanvasItem).hide()
	%Receipt.remove_child(%Receipt.get_child(0))
	pass  # Replace with function body.


func _process(delta: float) -> void:
	var receipt_control := %Receipt as Control
	var container_height := receipt_control.get_parent_area_size().y
	var own_height := receipt_control.size.y

	var offset := minf(0.0, container_height - own_height)
	receipt_control.position = receipt_control.position.lerp(Vector2(0, offset), delta * 20)

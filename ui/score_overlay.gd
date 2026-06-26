extends Control

class_name UI_ScoreOverlay

var time := 0.:
	set(val):
		time = val
		update_time_sway()
var sway := 0.:
	set(val):
		sway = val
		update_time_sway()


func update_time_sway() -> void:
	(%SwayLabel as Label).text = Helper.format_size(sway)
	(%TimeLabel as Label).text = ("%.2f" % time) + "s"


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
	_change_viz()
	CurrentRunState.inventory_handler.item_got_held.connect(
		func(_name: String) -> void: _change_viz()
	)

	(%BigNumber.get_parent() as CanvasItem).hide()
	%Receipt.remove_child(%Receipt.get_child(0))


func _change_viz() -> void:
	visible = (
			CurrentRunState
			.inventory_handler
			.is_holding_item(
				"ui1.tres",
			)
	)
	(%ExtraUI as Control).visible = (
			CurrentRunState
			.inventory_handler
			.is_holding_item(
				"ui2.tres",
			)
	)


func _process(delta: float) -> void:
	var receipt_control := %Receipt as Control
	var container_height := receipt_control.get_parent_area_size().y
	var own_height := receipt_control.size.y

	var offset := minf(0.0, container_height - own_height)
	receipt_control.position = receipt_control.position.lerp(Vector2(0, offset), delta * 20)

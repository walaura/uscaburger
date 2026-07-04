class_name UiScoreOverlay
extends Control

var time := 0.:
	set(val):
		time = val
		update_time_sway()
var sway := 0.:
	set(val):
		sway = val
		update_time_sway()

var _mode: ScTower.Mode


func setup(mode: ScTower.Mode) -> void:
	_mode = mode


func update_time_sway() -> void:
	(%SwayLabel as Label).text = Helper.format_size(sway)
	(%TimeLabel as Label).text = ("%.2f" % time) + "s"


func push(line_item: String, value: int) -> void:
	push_ticker_line(line_item, value)
	(%BigNumber as UiScoreOverlayBigNumber).add_to_score(value)


func push_ticker_line(line_item: String, value: int) -> void:
	(%BigNumber.get_parent() as CanvasItem).show()
	var label := %TickerItem.duplicate() as UiScoreOverlayTickerItem
	%Receipt.add_child(label)
	label.push(line_item, value)


func get_big_number() -> UiScoreOverlayBigNumber:
	return %BigNumber


func _ready() -> void:
	_change_viz()
	_set_mode()
	CurrentRun.inventory.item_got_held.connect(func(_name: RsItem) -> void: _change_viz())

	(%BigNumber.get_parent() as CanvasItem).hide()
	%Receipt.remove_child(%Receipt.get_child(0))


func _change_viz() -> void:
	visible = (CurrentRun.inventory.is_holding_key("ui1.tres"))
	(%ExtraUI as Control).visible = (CurrentRun.inventory.is_holding_key("ui2.tres"))


func _set_mode() -> void:
	match _mode:
		ScTower.Mode.Vegan:
			($BigNumberBG as Panel).material.set("shader_parameter/HSV", Vector3(.236, .3, -.3))
			(%BigNumber as UiScoreOverlayBigNumber).multi = 2.
		ScTower.Mode.Chicken:
			($BigNumberBG as Panel).material.set("shader_parameter/HSV", Vector3(.076, 0., 0.))
			(%BigNumber as UiScoreOverlayBigNumber).multi = 1.
		_:
			($BigNumberBG as Panel).material.set("shader_parameter/HSV", Vector3(0, 0, 0))
			(%BigNumber as UiScoreOverlayBigNumber).multi = 1.

	pass


func _process(delta: float) -> void:
	var receipt_control := %Receipt as Control
	var container_height := receipt_control.get_parent_area_size().y
	var own_height := receipt_control.size.y

	var offset := minf(0.0, container_height - own_height)
	receipt_control.position = receipt_control.position.lerp(Vector2(0, offset), delta * 20)

class_name Scene_Tower_ScoreHandler
extends Resource

var current_session_score := 0
var appearances: Dictionary[String, int] = {}
var previous_item := "no"

var sauce_cooldown_mult := 0
var sauce_cooldown := 6

var _mode := Scene_Tower.Mode.Normal


func _init(nw_mode: Scene_Tower.Mode = _mode) -> void:
	_mode = nw_mode


func push(droppable: Droppable, stack_height: float) -> Array[Scene_Tower_ScoreHandler_Line]:
	var key := droppable.receipt_name
	var price := droppable.price
	var returnable: Array[Scene_Tower_ScoreHandler_Line] = []
	returnable.push_back(_push_line(key, price))

	if !appearances.has(key):
		appearances.set(key, -1)
	appearances[key] += 1

	## find mult (apppearances + .1x)
	if CurrentRunState.inventory_handler.is_holding_item("condi_mult.tres"):
		var condi_mult := CurrentRunState.inventory_handler.get_item("condi_mult.tres")
		var mult := appearances[key]
		if mult > 0:
			var extra := (price / 100. * condi_mult.incremental_value) * mult
			(
				returnable
				. push_back(
					_push_line(
						"+ " + "%d" % mult + "x @" + (" %d" % condi_mult.incremental_value) + "%",
						int(extra),
					),
				)
			)

	## double?
	if CurrentRunState.inventory_handler.is_holding_item("condi_mult_row.tres"):
		if previous_item == key:
			returnable.push_back(_push_line("+ Two in a row!!", price * 3))

	## find height mult
	if CurrentRunState.inventory_handler.is_holding_item("condi_mult_moon.tres"):
		var condi_mult := CurrentRunState.inventory_handler.get_item("condi_mult_moon.tres")

		var height := Helper.size_in_units(stack_height)
		if height > 1.:
			var extra := price * ((height - 1) / 100 * condi_mult.incremental_value)
			(
				returnable
				. push_back(
					_push_line(
						(
							"+ %s @ %s%%"
							% [Helper.format_size(stack_height), str(condi_mult.incremental_value)]
						),
						int(extra),
					),
				)
			)

	##wrap up
	previous_item = key

	return returnable


func _push_line(key: String, value: int) -> Scene_Tower_ScoreHandler_Line:
	current_session_score += value
	return Scene_Tower_ScoreHandler_Line.new(key, value)


class Scene_Tower_ScoreHandler_Line:
	extends Resource
	var title: String
	var value: int

	func _init(nw_title: String, nw_value: int) -> void:
		title = nw_title
		value = nw_value

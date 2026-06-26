extends Node

class_name Scene_Tower_ScooreHandler

var current_session_score := 0
var appearances: Dictionary[String, int] = {}
var previous_item := "no"

var sauce_cooldown_mult := 0
var sauce_cooldown := 0

@export var overlay_ui: UI_ScoreOverlay


func push(droppable: Droppable) -> void:
	var key := droppable.receipt_name
	var price := droppable.price
	_push_line(key, price)

	if !appearances.has(key):
		appearances.set(key, -1)
	appearances[key] += 1

	## find mult (apppearances + .1x)
	if CurrentRunState.inventory_handler.is_holding_item("condi_mult.tres"):
		var condi_mult := CurrentRunState.inventory_handler.get_item("condi_mult.tres")
		var mult := appearances[key]
		if mult > 0:
			var extra := (price / 100. * condi_mult.incremental_value) * mult
			_push_line(
				"+ " + "%d" % mult + "x " + key + (" (%d" % condi_mult.incremental_value) + "%)",
				int(extra)
			)

	## double?
	if CurrentRunState.inventory_handler.is_holding_item("condi_mult_row.tres"):
		if previous_item == key:
			_push_line("+ Two in a row!!", price * 10)

	##wrap up
	previous_item = key


func _push_line(key: String, value: int) -> void:
	overlay_ui.push(key, value)
	current_session_score += value
	overlay_ui.get_big_number().set_score(current_session_score)

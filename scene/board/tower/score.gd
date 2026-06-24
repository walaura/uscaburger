extends Node

class_name Scene_Tower_ScooreHandler

var current_session_score := 0
var appearances: Dictionary[String, int] = { }
var previous_item := "no"

var sauce_cooldown_mult := 0
var sauce_cooldown := 0

@export var overlay_ui: UI_ScoreOverlay


func push(droppable: Droppable) -> void:
	var key := droppable.receipt_name
	var price := droppable.price
	_push_line(key, price)

	## find mult (apppearances + .1x)
	if !appearances.has(key):
		appearances.set(key, -1)
	appearances[key] += 1
	var mult := appearances[key] / 10.0
	if mult > 0:
		var extra := price * mult
		var mult_dsp := "%.1f" % (1 + mult)
		_push_line("+ Multiple (" + mult_dsp + "x)", int(extra))

	## double?
	if previous_item == key:
		_push_line("+ STACK", price * 10)

	##wrap up
	previous_item = key


func _push_line(key: String, value: int) -> void:
	overlay_ui.push(key, value)
	current_session_score += value
	overlay_ui.get_big_number().set_score(current_session_score)

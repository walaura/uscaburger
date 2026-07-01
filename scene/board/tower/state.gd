class_name ScTower_State
extends Resource

var current_session_score := 0
var appearances: Dictionary[String, int] = {}
var previous_item := "no"

var sauce_cooldown_mult := 0
var sauce_cooldown := 6

var _mode := ScTower.Mode.Normal

var EGG_KEY := ScTower_Parts.get_item("egg").name
var BACON_KEY := ScTower_Parts.get_item("bacon").name
var ONION_KEY := ScTower_Parts.get_item("onion").name


func _init(nw_mode: ScTower.Mode = _mode) -> void:
	_mode = nw_mode


func push(part: RsPart, stack_height: float) -> Array[ScTower_State_Line]:
	var key := part.name
	var price := part.price
	var returnable: Array[ScTower_State_Line] = []
	returnable.push_back(_push_line(key, price))

	if !appearances.has(key):
		appearances.set(key, 0)
	appearances[key] += 1

	## find mult (apppearances + .1x)
	if CurrentRun.inventory.is_holding_item("condi_mult.tres"):
		var condi_mult := CurrentRun.inventory.get_item("condi_mult.tres")
		var mult := appearances[key] - 1
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

	## find onion mult (1.5x per onion already there)
	if part.is_meat:
		var onions_count: int = appearances.get(ONION_KEY, 0)
		var mult := (price * 1.5 * onions_count) - price
		if mult > 0.0:
			returnable.push_back(_push_line("+ " + "%d" % onions_count + " " + ("onion" if onions_count == 1 else "onions"), int(mult)))

	## bacon + eggs
	if part.name == BACON_KEY:
		var eggs_count: int = appearances.get(EGG_KEY, 0)
		var mult := (price * 10 * (eggs_count)) - price
		if mult > 0.0:
			returnable.push_back(_push_line("+ " + "%d" % eggs_count + " " + ("egg" if eggs_count == 1 else "eggs"), int(mult)))

	## bacon gives 1.125x the whole score
	if part.name == BACON_KEY:
		var mult := (current_session_score * 1.125) - current_session_score
		if mult > 0.0:
			returnable.push_back(_push_line("+ Tasty!", int(mult)))

	## double?
	if CurrentRun.inventory.is_holding_item("condi_mult_row.tres"):
		if previous_item == key:
			returnable.push_back(_push_line("+ Two in a row!!", price * 3))

	## find height mult
	if CurrentRun.inventory.is_holding_item("condi_mult_moon.tres"):
		var condi_mult := CurrentRun.inventory.get_item("condi_mult_moon.tres")

		var height := Helper.size_in_units(stack_height)
		if height > 1.:
			var extra := price * ((height - 1) / 100 * condi_mult.incremental_value)
			(
				returnable
				. push_back(
					_push_line(
						"+ %s @ %s%%" % [Helper.format_size(stack_height), str(condi_mult.incremental_value)],
						int(extra),
					),
				)
			)

	##wrap up
	previous_item = key

	return returnable


func _push_line(key: String, value: int) -> ScTower_State_Line:
	current_session_score += value
	return ScTower_State_Line.new(key, value)


class ScTower_State_Line:
	extends Resource
	var title: String
	var value: int

	func _init(nw_title: String, nw_value: int) -> void:
		title = nw_title
		value = nw_value

extends Node

class_name CurrentRunState_Score

var current_session_score := 0
var last_settled_score: Array[CurrentRunState_ScoreLineItemResource] = []

const SALES_TAX_BASE := .20
const STAFF_BASE := .30


func push(score: int) -> void:
	current_session_score += score


func purchase(price: int) -> Array[CurrentRunState_ScoreLineItemResource]:
	push(-price)
	var tot := _mk_line("New balance", current_session_score)
	tot.is_total = true
	var tx: Array[CurrentRunState_ScoreLineItemResource] = [
		_mk_divider(false), _mk_line("This purchase", -price), tot
	]

	last_settled_score.append_array(tx)
	return tx


func get_staff_salaries_perc() -> float:
	var staff_salaries := STAFF_BASE
	if CurrentRunState.inventory_handler.is_holding_item("labor.tres"):
		var discount := CurrentRunState.inventory_handler.get_item("labor.tres")
		staff_salaries = STAFF_BASE - (staff_salaries / 100 * discount.incremental_value)
	return staff_salaries


func get_bom_perc() -> float:
	return .25


func get_sales_tax_perc() -> float:
	var sales_tax := SALES_TAX_BASE
	if CurrentRunState.inventory_handler.is_holding_item("salestax.tres"):
		var discount := CurrentRunState.inventory_handler.get_item("salestax.tres")
		sales_tax = SALES_TAX_BASE - (sales_tax / 100 * discount.incremental_value)
	return sales_tax


func get_currency_fx_perc() -> float:
	if CurrentRunState.inventory_handler.is_holding_item("currency_fx.tres"):
		var fx_fees_res := CurrentRunState.inventory_handler.get_item("currency_fx.tres")
		return fx_fees_res.incremental_value / 100
	return 0.


func settle_loss(score: int) -> void:
	last_settled_score = []
	last_settled_score.push_back(_mk_line("Nothing Burger", 0))
	var bom_line := _mk_deduction_line("Cost of materials", score, get_bom_perc())
	last_settled_score.push_back(bom_line)
	var insurance_line := bom_line.duplicate() as CurrentRunState_ScoreLineItemResource
	@warning_ignore("integer_division")
	insurance_line.value = int(insurance_line.value / -2)
	insurance_line.explanation = "Insurance"
	last_settled_score.push_back(insurance_line)

	var sub: int = last_settled_score.reduce(
		func(acc: int, cur: CurrentRunState_ScoreLineItemResource) -> int: return cur.value + acc,
		0,
	)

	push(sub)
	last_settled_score.push_back(_mk_divider(false))
	last_settled_score.push_back(_mk_divider(true))

	last_settled_score.push_back(_mk_line("Total", sub))

	var tot := _mk_line("Your balance", current_session_score)
	tot.is_total = true
	last_settled_score.push_back(tot)

	last_settled_score.push_back(_mk_divider(true))


func settle(score: int) -> void:
	last_settled_score = []

	last_settled_score.push_back(_mk_line("Gross revenue", score))
	last_settled_score.push_back(_mk_deduction_line("Cost of materials", score, get_bom_perc()))
	last_settled_score.push_back(
		_mk_deduction_line("Staffing costs", score, get_staff_salaries_perc())
	)

	last_settled_score.push_back(CurrentRunState_ScoreLineItemDividerResource.new())
	var sub: int = last_settled_score.reduce(
		func(acc: int, cur: CurrentRunState_ScoreLineItemResource) -> int: return cur.value + acc,
		0,
	)
	last_settled_score.push_back(_mk_line("Subtotal", sub))
	last_settled_score.push_back(_mk_divider(false))

	# Sales tax & tot
	var sales_tax_line := _mk_deduction_line("Sales tax", score, get_sales_tax_perc())
	last_settled_score.push_back(sales_tax_line)

	var tot1 := sub + sales_tax_line.value

	# currency_fx
	var currency_fx_line := _mk_deduction_line("FX fees", score, get_currency_fx_perc())
	if currency_fx_line != null:
		last_settled_score.push_back(currency_fx_line)
		tot1 += currency_fx_line.value

	last_settled_score.push_back(_mk_divider(false))
	last_settled_score.push_back(_mk_divider(true))

	push(tot1)
	last_settled_score.push_back(_mk_line("Total", tot1))

	var tot := _mk_line("Your balance", current_session_score)
	tot.is_total = true
	last_settled_score.push_back(tot)

	last_settled_score.push_back(_mk_divider(true))


func _minus_perc(number: int, perc: float) -> int:
	var perc_val := int((float(number) / 1.) * perc)
	return (perc_val) * -1


func _mk_divider(is_empty_line: bool) -> CurrentRunState_ScoreLineItemDividerResource:
	var line := CurrentRunState_ScoreLineItemDividerResource.new()
	line.is_empty_line = is_empty_line
	return line


func _mk_line(explanation: String, value: int) -> CurrentRunState_ScoreLineItemResource:
	var line := CurrentRunState_ScoreLineItemResource.new()
	line.value = value
	line.explanation = explanation
	return line


func _mk_deduction_line(
	reason: String, number: int, perc: float
) -> CurrentRunState_ScoreLineItemResource:
	if perc == 0.:
		return null
	print(perc, reason)
	var num = (
		"%d%% %s" % [int(perc * 100), reason]
		if perc >= 0.01
		else "%.2f%% %s" % [perc * 100, reason]
	)
	return _mk_line(num, _minus_perc(number, perc))

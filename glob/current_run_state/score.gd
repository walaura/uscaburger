extends Node

class_name CurrentRunState_Score

var current_session_score := 0
var last_settled_score: Array[CurrentRunState_ScoreLineItemResource] = []
var _insurance_used := -3

const BOM_BASE := .25
const SALES_TAX_BASE := .20
const STAFF_BASE := .30


func purchase(price: int) -> Array[CurrentRunState_ScoreLineItemResource]:
	_push(-price)
	var tot := CurrentRunState_ScoreLineItemResource.new("Balance", current_session_score)
	tot.is_total = true
	var tx: Array[CurrentRunState_ScoreLineItemResource] = [
		CurrentRunState_ScoreLineItemDividerResource.new(),
		CurrentRunState_ScoreLineItemResource.new("This purchase", -price),
		tot,
	]

	last_settled_score.append_array(tx)
	return tx


func settle_loss(score_handler: Scene_Tower_ScoreHandler) -> void:
	var score := score_handler.current_session_score
	var tx: Array[CurrentRunState_ScoreLineItemResource] = []

	tx.push_back(CurrentRunState_ScoreLineItemResource.new("Nothing Burger", 0))
	var bom_line := _mk_deduction_line("Cost of materials", score, _get_bom_perc())
	tx.push_back(bom_line)
	tx.push_back(_mk_insurance_line(bom_line.value))

	var sub: int = tx.reduce(
		func(acc: int, cur: CurrentRunState_ScoreLineItemResource) -> int: return cur.value + acc,
		0,
	)

	tx.push_back(CurrentRunState_ScoreLineItemDividerResource.new())
	tx.append_array(_print_total(sub))

	_push(sub)
	last_settled_score = tx
	_insurance_used += 1


func settle(score_handler: Scene_Tower_ScoreHandler) -> void:
	var score := score_handler.current_session_score
	var tx: Array[CurrentRunState_ScoreLineItemResource] = []

	tx.push_back(CurrentRunState_ScoreLineItemResource.new("Gross revenue", score))

	# vegan?
	if score_handler._mode == Scene_Tower.Mode.Vegan:
		tx.push_back(CurrentRunState_ScoreLineItemResource.new("2x Markup", score))

	tx.push_back(_mk_deduction_line("Cost of materials", score, _get_bom_perc()))
	(
		tx
		. push_back(
			_mk_deduction_line("Staffing costs", score, _get_staff_salaries_perc()),
		)
	)

	tx.push_back(CurrentRunState_ScoreLineItemDividerResource.new())
	var sub: int = tx.reduce(
		func(acc: int, cur: CurrentRunState_ScoreLineItemResource) -> int: return cur.value + acc,
		0,
	)
	tx.push_back(CurrentRunState_ScoreLineItemResource.new("Subtotal", sub))
	tx.push_back(CurrentRunState_ScoreLineItemDividerResource.new())

	# Sales tax & tot
	var sales_tax_line := _mk_deduction_line("Sales tax", score, _get_sales_tax_perc())
	tx.push_back(sales_tax_line)
	var tot1 := sub + sales_tax_line.value

	# currency_fx
	tx.push_back(_mk_deduction_line("FX fees", score, _get_currency_fx_perc()))

	tx.push_back(CurrentRunState_ScoreLineItemDividerResource.new())
	tx.append_array(_print_total(tot1))

	_push(tot1)
	last_settled_score = tx


func _mk_insurance_line(bom_value: int) -> CurrentRunState_ScoreLineItemResource:
	match _insurance_used:
		-3:
			return CurrentRunState_ScoreLineItemResource.new(
				"Insurance (No claims Bonus)", int(bom_value / -1.)
			)
		-2:
			return CurrentRunState_ScoreLineItemResource.new(
				"Insurance (Silver plan)", int(bom_value / -2.)
			)
		-1:
			return CurrentRunState_ScoreLineItemResource.new(
				"Insurance (Loan shark)", int(bom_value / -4.)
			)
		0:
			return CurrentRunState_ScoreLineItemResource.new(
				"Time spent on angry phone call w/ loan shark", -299
			)
		_:
			var perc := int(_insurance_used * 5)
			return CurrentRunState_ScoreLineItemResource.new(
				"%d%%" % (perc) + " Protection money (Loan shark)", int(bom_value / 100. * perc)
			)


func _get_staff_salaries_perc() -> float:
	var staff_salaries := STAFF_BASE
	if CurrentRunState.inventory_handler.is_holding_item("labor.tres"):
		var discount := CurrentRunState.inventory_handler.get_item("labor.tres")
		staff_salaries = STAFF_BASE - (staff_salaries / 100 * discount.incremental_value)
	return staff_salaries


func _get_bom_perc() -> float:
	var bom := BOM_BASE
	if CurrentRunState.inventory_handler.is_holding_item("bom.tres"):
		var discount := CurrentRunState.inventory_handler.get_item("bom.tres")
		bom = BOM_BASE - (bom / 100 * discount.incremental_value)
	return bom


func _get_sales_tax_perc() -> float:
	var sales_tax := SALES_TAX_BASE
	if CurrentRunState.inventory_handler.is_holding_item("salestax.tres"):
		var discount := CurrentRunState.inventory_handler.get_item("salestax.tres")
		sales_tax = SALES_TAX_BASE - (sales_tax / 100 * discount.incremental_value)
	return sales_tax


func _get_currency_fx_perc() -> float:
	if CurrentRunState.inventory_handler.is_holding_item("currency_fx.tres"):
		var fx_fees_res := CurrentRunState.inventory_handler.get_item("currency_fx.tres")
		return fx_fees_res.incremental_value / 100
	return 0.


func _print_total(total: int) -> Array[CurrentRunState_ScoreLineItemResource]:
	var tx: Array[CurrentRunState_ScoreLineItemResource] = []
	tx.push_back(CurrentRunState_ScoreLineItemResource.new("Total", total))
	tx.push_back(CurrentRunState_ScoreLineItemBrResource.new())
	tx.push_back(CurrentRunState_ScoreLineItemResource.new("In your wallet", current_session_score))
	tx.push_back(
		CurrentRunState_ScoreLineItemResource.new("Balance", current_session_score + total, true)
	)
	tx.push_back(CurrentRunState_ScoreLineItemBrResource.new())
	return tx


func _push(score: int) -> void:
	current_session_score += score


func _minus_perc(number: int, perc: float) -> int:
	var perc_val := int((float(number) / 1.) * perc)
	return (perc_val) * -1


func _mk_deduction_line(
	reason: String,
	number: int,
	perc: float,
) -> CurrentRunState_ScoreLineItemResource:
	if perc == 0.:
		return CurrentRunState_ScoreLineItemNullResource.new()
	var num := (
		"%d%% %s" % [int(perc * 100), reason]
		if abs(perc) >= 0.01
		else "%.2f%% %s" % [perc * 100, reason]
	)
	return CurrentRunState_ScoreLineItemResource.new(num, _minus_perc(number, perc))

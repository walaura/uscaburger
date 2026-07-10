class_name CurrentRun_Score
extends RefCounted

var burger_history: Array[RsBurgerStats] = []
var total_money_earned := 0
var current_session_score := 0
var last_settled_score: Array[CurrentRun_ScoreLineItemResource] = []

var parts_to_close := Helper.MIN_TO_CLOSE

var _insurance_used := -3

const BOM_BASE := .25
const SALES_TAX_BASE := .20
const STAFF_BASE := .30


func on_item_got_held(item: RsItem) -> void:
	if item.get_key() == "hotbuns.tres":
		parts_to_close = ceili(parts_to_close / 2.0)


func finalize_burger(stats: RsBurgerStats) -> void:
	burger_history.push_back(stats)
	if stats is not RsFailedBurgerStats:
		parts_to_close += 1


func get_record_burger(record: RsBurgerStats.Record) -> RsBurgerStats:
	if burger_history.size() == 0:
		return null
	match record:
		RsBurgerStats.Record.PRICE:
			return burger_history.reduce(
				func(winner: RsBurgerStats, current: RsBurgerStats) -> RsBurgerStats:
					if current.price > winner.price:
						return current
					return winner,
				RsBurgerStats.new()
			)
		RsBurgerStats.Record.HEIGHT:
			return burger_history.reduce(
				func(winner: RsBurgerStats, current: RsBurgerStats) -> RsBurgerStats:
					if current.height > winner.height:
						return current
					return winner,
				RsBurgerStats.new()
			)
		_:
			return burger_history.reduce(
				func(winner: RsBurgerStats, current: RsBurgerStats) -> RsBurgerStats:
					if current.length > winner.length:
						return current
					return winner,
				RsBurgerStats.new()
			)


func purchase(price: int) -> Array[CurrentRun_ScoreLineItemResource]:
	_push(-price)
	var tot := CurrentRun_ScoreLineItemResource.new("Balance", current_session_score)
	tot.is_total = true
	var tx: Array[CurrentRun_ScoreLineItemResource] = [
		CurrentRun_ScoreLineItemDividerResource.new(),
		CurrentRun_ScoreLineItemResource.new("This purchase", -price),
		tot,
	]

	last_settled_score.append_array(tx)
	return tx


func settle_loss(state: ScTower_State) -> void:
	var score := state.current_session_score
	var tx: Array[CurrentRun_ScoreLineItemResource] = []

	tx.push_back(CurrentRun_ScoreLineItemResource.new("Nothing Burger", 0))
	var bom_line := _mk_deduction_line("Cost of materials", score, _get_bom_perc())
	tx.push_back(bom_line)
	tx.push_back(_mk_insurance_line(bom_line.value))

	var sub: int = tx.reduce(
		func(acc: int, cur: CurrentRun_ScoreLineItemResource) -> int: return cur.value + acc,
		0,
	)

	tx.push_back(CurrentRun_ScoreLineItemDividerResource.new())
	tx.append_array(_print_total(sub))

	_push(sub)
	last_settled_score = tx
	_insurance_used += 1


func settle(state: ScTower_State) -> void:
	var score := state.current_session_score
	var tx: Array[CurrentRun_ScoreLineItemResource] = []

	tx.push_back(CurrentRun_ScoreLineItemResource.new("Gross revenue", score))

	# vegan?
	if state._mode == ScTower.Mode.Vegan:
		tx.push_back(CurrentRun_ScoreLineItemResource.new("2x Markup", score))

	tx.push_back(_mk_deduction_line("Cost of materials", score, _get_bom_perc()))
	(
		tx
		. push_back(
			_mk_deduction_line("Staffing costs", score, _get_staff_salaries_perc()),
		)
	)

	tx.push_back(CurrentRun_ScoreLineItemDividerResource.new())
	var sub: int = tx.reduce(
		func(acc: int, cur: CurrentRun_ScoreLineItemResource) -> int: return cur.value + acc,
		0,
	)
	tx.push_back(CurrentRun_ScoreLineItemResource.new("Subtotal", sub))
	tx.push_back(CurrentRun_ScoreLineItemDividerResource.new())

	# Sales tax & tot
	var sales_tax_line := _mk_deduction_line("Sales tax", score, _get_sales_tax_perc())
	tx.push_back(sales_tax_line)
	var tot1 := sub + sales_tax_line.value

	# currency_fx
	tx.push_back(_mk_deduction_line("FX fees", score, _get_currency_fx_perc()))

	tx.push_back(CurrentRun_ScoreLineItemDividerResource.new())
	tx.append_array(_print_total(tot1))

	_push(tot1)
	last_settled_score = tx


func _mk_insurance_line(bom_value: int) -> CurrentRun_ScoreLineItemResource:
	match _insurance_used:
		-3:
			return CurrentRun_ScoreLineItemResource.new("Insurance (No claims Bonus)", int(bom_value / -1.))
		-2:
			return CurrentRun_ScoreLineItemResource.new("Insurance (Silver plan)", int(bom_value / -2.))
		-1:
			return CurrentRun_ScoreLineItemResource.new("Insurance (Loan shark)", int(bom_value / -4.))
		0:
			return CurrentRun_ScoreLineItemResource.new("Time spent on angry phone call w/ loan shark", -299)
		_:
			var perc := int(_insurance_used * 5)
			return CurrentRun_ScoreLineItemResource.new("%d%%" % (perc) + " Protection money (Loan shark)", int(bom_value / 100. * perc))


func _get_staff_salaries_perc() -> float:
	var staff_salaries := STAFF_BASE
	var maybe_discount := CurrentRun.inventory.get_held_item_by_key("disco_labor.tres")
	if maybe_discount != null:
		staff_salaries = STAFF_BASE - (staff_salaries / 100 * maybe_discount.incremental_value)
	return staff_salaries


func _get_bom_perc() -> float:
	var bom := BOM_BASE
	var maybe_discount := CurrentRun.inventory.get_held_item_by_key("disco_bom.tres")
	if maybe_discount != null:
		bom = BOM_BASE - (bom / 100 * maybe_discount.incremental_value)
	return bom


func _get_sales_tax_perc() -> float:
	var sales_tax := SALES_TAX_BASE
	var maybe_discount := CurrentRun.inventory.get_held_item_by_key("disco_salestax.tres")
	if maybe_discount != null:
		sales_tax = SALES_TAX_BASE - (sales_tax / 100 * maybe_discount.incremental_value)
	return sales_tax


func _get_currency_fx_perc() -> float:
	var maybe_fxf := CurrentRun.inventory.get_held_item_by_key("currency_fx.tres")
	if maybe_fxf != null:
		return maybe_fxf.incremental_value / 100
	return 0.


func _print_total(total: int) -> Array[CurrentRun_ScoreLineItemResource]:
	var tx: Array[CurrentRun_ScoreLineItemResource] = []
	tx.push_back(CurrentRun_ScoreLineItemResource.new("Total", total))
	tx.push_back(CurrentRun_ScoreLineItemBrResource.new())
	tx.push_back(CurrentRun_ScoreLineItemResource.new("In your wallet", current_session_score))
	tx.push_back(CurrentRun_ScoreLineItemResource.new("Balance", current_session_score + total, true))
	tx.push_back(CurrentRun_ScoreLineItemBrResource.new())
	return tx


func _push(score: int) -> void:
	total_money_earned += maxi(score, 0)
	current_session_score += score


func _minus_perc(number: int, perc: float) -> int:
	var perc_val := int((float(number) / 1.) * perc)
	return (perc_val) * -1


func _mk_deduction_line(
	reason: String,
	number: int,
	perc: float,
) -> CurrentRun_ScoreLineItemResource:
	if perc == 0.:
		return CurrentRun_ScoreLineItemNullResource.new()
	var num := "%d%% %s" % [int(perc * 100), reason] if abs(perc) >= 0.01 else "%.2f%% %s" % [perc * 100, reason]
	return CurrentRun_ScoreLineItemResource.new(num, _minus_perc(number, perc))

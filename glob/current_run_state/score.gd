extends Node

class_name CurrentRunState_Score

var current_session_score := 0
var last_settled_score: Array[CurrentRunState_ScoreLineItemResource] = []


func push(score: int) -> void:
	current_session_score += score


func settle(score: int) -> void:
	last_settled_score = []

	last_settled_score.push_back(_mk_line("This run", score))
	last_settled_score.push_back(_mk_line("40% Cost of materials", _minus_perc(score, .45)))
	last_settled_score.push_back(_mk_line("35% Staff salaries", _minus_perc(score, .35)))

	last_settled_score.push_back(CurrentRunState_ScoreLineItemDividerResource.new())
	var sub: int = last_settled_score.reduce(
		func(acc: int, cur: CurrentRunState_ScoreLineItemResource) -> int: return cur.value + acc,
		0,
	)
	last_settled_score.push_back(_mk_line("Subtotal", sub))

	last_settled_score.push_back(CurrentRunState_ScoreLineItemDividerResource.new())

	var tax := _minus_perc(sub, .20)
	last_settled_score.push_back(_mk_line("20% Sales tax", tax))

	last_settled_score.push_back(CurrentRunState_ScoreLineItemDividerResource.new())
	last_settled_score.push_back(_mk_divider(true))

	var tot := _mk_line("Total", sub + tax)
	tot.is_total = true
	last_settled_score.push_back(tot)
	last_settled_score.push_back(_mk_divider(true))

	push(sub + tax)


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

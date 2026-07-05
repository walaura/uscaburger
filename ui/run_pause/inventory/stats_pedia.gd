class_name UiInventoryPedia
extends Control


func _ready() -> void:
	var all_items: Array[RsBurgerStats] = CurrentRun.score.burger_history.duplicate()
	all_items.reverse()
	if all_items.size() == 0:
		($Early as Control).show()
		(%Stats as Control).hide()
		return

	($Early as Control).hide()
	(%Stats as Control).show()

	var all_successful := all_items.filter(func(item: RsBurgerStats) -> bool: return item is not RsFailedBurgerStats)

	(%Count as Label).text = "%d Total, %d Succesful" % [all_items.size(), all_successful.size()]

	var expensivest := CurrentRun.score.get_record_burger(RsBurgerStats.Record.PRICE)

	for item in all_items:
		var divider := ColorRect.new()
		divider.color = Helper.COLOR_TEAL
		divider.custom_minimum_size.y = 1.5
		if item != all_items[0]:
			(%Table as Container).add_child(divider)

		if item is RsFailedBurgerStats:
			var fail: Control = %Fail.duplicate()
			fail.visible = true
			(%Table as Container).add_child(_with_margin_box(fail))
			continue

		var row: UiStatsPediaRow = %Row.duplicate()
		row.price = item.price
		row.height = item.height
		row.length = item.length
		row.is_winner = item == expensivest
		(%Table as Container).add_child(_with_margin_box(row))


func _with_margin_box(child: Node) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_bottom", 4)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_child(child)
	return margin

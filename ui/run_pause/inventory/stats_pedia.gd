class_name UiInventoryPedia
extends Control


func _ready() -> void:
	var all_items := CurrentRun.score.burger_history
	if all_items.size() == 0:
		($Early as Control).show()
		($Stats as Control).hide()
		return

	($Early as Control).hide()
	($Stats as Control).show()

	(%Total as Label).text = str(all_items.size())

	all_items.sort_custom(func(a: RsBurgerStats, b: RsBurgerStats) -> int: return b.price - a.price)
	(%Expensivest as Label).text = Helper.format_currency(all_items[0].price)

	all_items.sort_custom(func(a: RsBurgerStats, b: RsBurgerStats) -> int: return b.length - a.length)
	(%MostParts as Label).text = str(all_items[0].length)

	all_items.sort_custom(func(a: RsBurgerStats, b: RsBurgerStats) -> float: return b.height - a.height)
	(%Tallest as Label).text = Helper.format_size(all_items[0].height)

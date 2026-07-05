class_name UiCollectionPedia
extends Control


func _ready() -> void:
	var all_items := SavedRecords.records
	if all_items.tot == null or all_items.tot.record == 0:
		($Early as Control).show()
		($Stats as Control).hide()
		return

	($Early as Control).hide()
	($Stats as Control).show()

	(%Total as Label).text = Helper.format_number_with_commas(mini(999999999, all_items.tot.record))
	(%Expensivest as Label).text = Helper.format_currency(all_items.max_money.record)
	(%ExpensivestDate as Label).text = Helper.format_unix_date(all_items.max_money.saved_at)

	(%MostParts as Label).text = str(all_items.max_parts.record)
	(%MostPartsDate as Label).text = Helper.format_unix_date(all_items.max_parts.saved_at)

	(%Tallest as Label).text = Helper.format_size(all_items.max_height.record)
	(%TallestDate as Label).text = Helper.format_unix_date(all_items.max_height.saved_at)

@tool
class_name UiInventoryItemDetails
extends Control

@export var item: RsItem:
	set(value):
		item = value
		queue_redraw()


func _draw() -> void:
	if not is_node_ready():
		await ready

	if SavedRecords.records.has_seen_badge(item):
		($Deets/VBoxContainer/Label as Label).text = item.name
		($Deets/VBoxContainer/Price as Label).text = Helper.format_currency(item.price)
		($Deets/BadgeImg as UiKetchupBadge).icon = item.icon
		($Deets/BadgeImg as UiKetchupBadge).tier = item.get_tier_for_display()

		($Deets/VBoxContainer/Powers as RichTextLabel).text = item.desc
		($Early as Label).hide()
		($Deets as Control).show()
	else:
		($Early as Label).show()
		($Deets as Control).hide()

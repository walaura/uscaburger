@tool
class_name UiInventoryItemDetails
extends Control

@export var item: RsItem:
	set(value):
		item = value
		if not is_node_ready():
			await ready
		_redraw_ui()


func _redraw_ui() -> void:
	($VBoxContainer/Label as Label).text = item.name
	($BadgeImg as UiKetchupBadge).icon = item.icon
	($BadgeImg as UiKetchupBadge).tier = item.get_tier_for_display()

	($VBoxContainer/Powers as RichTextLabel).text = item.desc

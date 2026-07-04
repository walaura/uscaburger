class_name UiInventoryStatsFx
extends Control


func _ready() -> void:
	var all_items := CurrentRun.inventory._held_items
	if(all_items.size() == 0):
		($Early as Control).show()
		return
	
	($Early as Control).hide()
	for item_name in all_items:
		var item := CurrentRun.inventory.get_item_at_held_tier(CurrentRun_Inventory._get_item_raw(item_name))
		if item.fx_short_desc == null or item.fx_short_desc.length() < 2:
			continue
		var label := RichTextLabel.new()
		label.bbcode_enabled = true
		label.install_effect(RichTextFxBoing.new())
		label.fit_content = true
		label.text = item.fx_short_desc
		$VBoxContainer.add_child(label)

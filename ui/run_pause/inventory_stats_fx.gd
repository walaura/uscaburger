class_name UiInventoryStatsFx
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var all_items := CurrentRun.inventory._held_items
	for item_name in all_items:
		var item := CurrentRun.inventory.get_item(item_name)
		if item.fx_short_desc == null or item.fx_short_desc.length() < 2:
			continue
		var label := RichTextLabel.new()
		label.bbcode_enabled = true
		label.install_effect(RichTextFxBoing.new())
		label.fit_content = true
		label.text = item.fx_short_desc
		print(label)
		$VBoxContainer.add_child(label)
	print(JSON.stringify(CurrentRun.inventory._held_items, " "))
	pass  # Replace with function body.

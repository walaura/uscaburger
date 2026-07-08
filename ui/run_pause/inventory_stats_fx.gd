class_name UiInventoryStatsFx
extends Control


func _ready() -> void:
	$VBoxContainer.add_child(
		_make_label("[boing]%d[/boing] parts needed for a top bun (+1 per successful burger)" % CurrentRun.score.parts_to_close)
	)
	
	for item_name in CurrentRun.inventory._held_items:
		var item := CurrentRun.inventory.get_item_at_held_tier(CurrentRun_Inventory._get_item_raw(item_name))
		if item.fx_short_desc == null or item.fx_short_desc.length() < 2:
			continue
		$VBoxContainer.add_child(_make_label(item.fx_short_desc))


func _make_label(text: String) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.install_effect(RichTextFxBoing.new())
	label.fit_content = true
	label.text = text
	return label

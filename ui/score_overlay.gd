extends Control

class_name ScoreOverlay


func push(line_item: String, value: int):
	push_ticker_line(line_item, value)
	%BigNumber.add_to_score(value)


func push_ticker_line(line_item: String, value: int):
	var label = %TickerItem.duplicate()
	%Receipt.add_child(label)
	label.push(line_item, value)


func get_big_number() -> ScoreOverlayBigNumber:
	return %BigNumber


func _ready() -> void:
	%Receipt.remove_child(%Receipt.get_child(0))
	pass  # Replace with function body.


func _process(delta: float) -> void:
	var container_height = %Receipt.get_parent_area_size().y
	var own_height = %Receipt.size.y

	var offset = min(0.0, container_height - own_height)
	%Receipt.position = %Receipt.position.lerp(Vector2(0, offset), delta * 20)

	pass


func _on_button_pressed() -> void:
	push("walalalalalalalala", 799)


func _on_adds_button_pressed() -> void:
	%BigNumber.add_to_score(3463)
	pass  # Replace with function body.

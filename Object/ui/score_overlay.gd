extends Control

func push(line_item: String):
	var label = %TickerItem.duplicate()
	#label.text= 'item:'+line_item
	%Receipt.add_child(label)
	label.push(line_item, 269)


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	var container_height = %Receipt.get_parent_area_size().y
	var own_height = %Receipt.size.y
	
	var offset = min(0.0, container_height - own_height)
	Dp.push('ch',offset )
	%Receipt.position = %Receipt.position.lerp(Vector2(0,offset), delta * 20)
	
	pass


func _on_button_pressed() -> void:
	push('walalalalalalalala')

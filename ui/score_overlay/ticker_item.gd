extends HBoxContainer


func push(title: String, price: int) -> void:
	var player = Helper.add_animation(self)
	(get_child(0) as Label).text = title
	(get_child(1) as Label).text = "$ " + Helper.format_number(price / 100.0)
	player.play("animations/highlight")

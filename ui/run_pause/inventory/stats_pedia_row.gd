class_name UiStatsPediaRow
extends HBoxContainer

@export var is_winner := false
@export var price := 0
@export var height := 0.
@export var length := 0


func _draw() -> void:
	(%Price as Label).text = Helper.format_currency(price)
	(%Size as Label).text = Helper.format_size(height)
	(%Length as Label).text = "%d parts" % length

	if is_winner:
		(%Crown as Control).show()
		(%Price as Label).add_theme_color_override("font_color", Helper.COLOR_YELL)
	else:
		(%Crown as Control).hide()
		(%Price as Label).add_theme_color_override("font_color", Helper.COLOR_TEAL)

class_name UiXToClose
extends Control

@export var count := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if count == 1:
		(%Label as Label).text = "%d more part until you can get a top bun" % count
	else:
		(%Label as Label).text = "%d more parts until you can get a top bun" % count

class_name UiScoreOverlayBigNumber
extends Label

var score := 0
var display_score := 0

var multi := 1.:
	set(val):
		multi = val
		if multi < 1.1:
			($Multi as CanvasItem).hide()
		else:
			($Multi as CanvasItem).show()
			($"Multi/Label" as Label).text = str(int(multi)) + "x"


func set_score(val: int) -> void:
	score = val
	var tween := create_tween()
	tween.tween_property(self, "display_score", score, 1.).set_ease(Tween.EASE_IN_OUT)
	Helper.add_animation(self.get_parent()).play("animations/highlight")


func add_to_score(val: int) -> void:
	set_score(score + val)


func _process(_delta: float) -> void:
	self.text = Helper.format_currency(display_score * multi)

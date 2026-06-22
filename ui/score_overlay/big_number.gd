extends Label

class_name UI_ScoreOverlayBigNumber

var score := 0
var display_score := 0


func set_score(val: int) -> void:
	score = val
	var tween := create_tween()
	tween.tween_property(self, "display_score", score, 1.).set_ease(Tween.EASE_IN_OUT)
	Helper.add_animation(self.get_parent()).play("animations/highlight")


func add_to_score(val: int) -> void:
	set_score(score + val)


func _process(_delta: float) -> void:
	self.text = "$ " + Helper.format_number(display_score / 100.)
	pass

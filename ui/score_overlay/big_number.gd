extends Label

class_name ScoreOverlayBigNumber

var score := 0
var display_score := 0

var tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.get_parent().hide()
	pass  # Replace with function body.


func set_score(val: int):
	self.get_parent().show()
	score = val
	tween = create_tween()
	tween.tween_property(self, "display_score", score, 1.).set_ease(Tween.EASE_IN_OUT)
	Helper.add_animation(self.get_parent()).play("animations/highlight")


func add_to_score(val: int):
	set_score(score + val)


func _process(_delta: float) -> void:
	self.text = "$ " + Helper.format_number(display_score / 100.)
	pass

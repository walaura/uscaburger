class_name UI_ButtonPromptsTextBox extends PanelContainer

const HIGHLIGHT_ANIM = .25
var _should_dehighlight := false

@export var action: String:
	set(val):
		action = val
		(%ButtonPromptForAction as ButtonPromptForAction).action = val
		(%Label as Label).text = _get_action_name()


func _process(_delta: float) -> void:
	if _should_dehighlight and Input.is_action_pressed(action):
		_should_dehighlight = false
		dehighlight()


func highlight_til_pressed() -> void:
	highlight()
	_should_dehighlight = true


func highlight() -> void:
	var highlight_node := get_node("%PanelContainer") as CanvasItem
	var tween := create_tween()
	(
		tween
		. tween_property(self, "scale", Vector2(2, 2), HIGHLIGHT_ANIM)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_IN_OUT)
	)
	tween.parallel().tween_property(highlight_node, "modulate:a", 1, HIGHLIGHT_ANIM)
	tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)


func dehighlight() -> void:
	var highlight_node := get_node("%PanelContainer") as CanvasItem
	var tween := create_tween()
	(
		tween
		. tween_property(self, "scale", Vector2(1, 1), HIGHLIGHT_ANIM)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_IN_OUT)
	)
	tween.parallel().tween_property(highlight_node, "modulate:a", 0., HIGHLIGHT_ANIM)
	tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)


func _get_action_name() -> String:
	match action:
		"Drop":
			return "Drop piece"
		"Finish":
			return "Finish this burger"
		"Rotate-L", "Rotate-R":
			return "Rotate"
		_:
			return action

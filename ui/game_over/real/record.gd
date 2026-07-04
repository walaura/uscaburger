class_name UiGameOverRealRecord
extends HBoxContainer

@export var text: String = ""
@export var is_new_record: bool = false
@export var autoplay := true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	($PanelContainer as Control).modulate.a = 0
	($RichTextLabel as RichTextLabel).text = text
	($RichTextLabel as RichTextLabel).visible_ratio = 0.0
	if autoplay:
		animate_in()


func animate_in(tween: Tween = null) -> Tween:
	tween = TweenHelper.maybe_init(self, tween, Tween.EASE_OUT)
	tween.tween_property($RichTextLabel as RichTextLabel, "visible_ratio", 1.0, 2)
	if is_new_record:
		tween.tween_property($PanelContainer as Control, "modulate:a", 1.0, .5)

	return tween

class_name RichTextFxBoing
extends RichTextEffect

var bbcode := "boing"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.color = Color(1.0, 0.2, 0.078, 1.0)
	return true

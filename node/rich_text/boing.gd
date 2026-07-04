class_name RichTextFxBoing
extends RichTextEffect

var bbcode := "boing"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.color = Color("#00DCCE")
	return true

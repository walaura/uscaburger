class_name RichTextFxBoing
extends RichTextEffect

var bbcode := "boing"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.color = Helper.COLOR_TEAL_DARKER
	return true

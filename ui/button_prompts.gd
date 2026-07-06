class_name UiButtonPrompts
extends Control


func _ready() -> void:
	visible = true
	pass


func push(action: String) -> UiButtonPromptsTextBox:
	if %VBoxContainer.get_child_count():
		var last: UiButtonPromptsTextBox = %VBoxContainer.get_child(-1)
		last.dehighlight()
	var childv := preload("res://ui/button_prompts/button_prompts_text_box.tscn").instantiate() as UiButtonPromptsTextBox
	childv.action = action
	childv.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	%VBoxContainer.add_child(childv)
	return childv


func push_tutorial(action: String) -> void:
	push(action).highlight_til_pressed()


func push_pressable(action: String) -> void:
	push(action)


func _on_button_pressed() -> void:
	push_tutorial("Drop")

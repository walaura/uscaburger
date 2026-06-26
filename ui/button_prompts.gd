class_name UI_ButtonPrompts
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func push(action: String) -> UI_ButtonPromptsTextBox:
	if %VBoxContainer.get_child_count():
		var last: UI_ButtonPromptsTextBox = %VBoxContainer.get_child(-1)
		last.dehighlight()
	var childv := (
		preload("res://ui/button_prompts/button_prompts_text_box.tscn").instantiate()
		as UI_ButtonPromptsTextBox
	)
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

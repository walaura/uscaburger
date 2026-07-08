class_name PartsConfirm
extends Control

@export var message: String
@export var yeah_label: String
@export var nah_label: String


func _ready() -> void:
	_draw_ui()


func _input(event: InputEvent) -> void:
	InputHelper.force_grab_focus_on_input(event, %VBoxContainer as VBoxContainer)


func _draw_ui() -> void:
	visible = false
	($CanvasLayer as CanvasLayer).visible = false
	(%Yeah as Button).text = yeah_label
	(%Nay as Button).text = nah_label
	(%Title as Label).text = message


func confirm(on_yay: Callable, on_nay: Callable) -> void:
	visible = true
	($CanvasLayer as CanvasLayer).visible = true
	InputHelper.force_focus(%VBoxContainer as VBoxContainer)
	(%Yeah as Button).pressed.connect(
		func() -> void:
			on_yay.call()
			on_done()
	)
	(%Nay as Button).pressed.connect(
		func() -> void:
			on_nay.call()
			on_done()
	)


func on_done() -> void:
	queue_free()

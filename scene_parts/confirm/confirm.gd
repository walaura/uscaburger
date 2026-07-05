class_name PartsConfirm
extends Control

@export var message: String:
	set(val):
		message = val
		_draw_ui()
@export var yeah_label: String:
	set(val):
		yeah_label = val
		_draw_ui()
@export var nah_label: String:
	set(val):
		nah_label = val
		_draw_ui()


func _init() -> void:
	visible = false


func _ready() -> void:
	pass
	_draw_ui()


func _draw_ui() -> void:
	(%Yeah as Button).text = yeah_label
	(%Nay as Button).text = nah_label
	(%Title as Label).text = message


func confirm(on_yay: Callable, on_nay: Callable) -> void:
	visible = true
	position = Vector2.ZERO
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

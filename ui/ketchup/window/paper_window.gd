class_name UiKetchupPaperWindow
extends Control

@export var open_on_ready := true

signal animation_in_almost_ready
signal animation_out_almost_ready


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	($SubViewport/ColorRect as ColorRect).material.set("shader_parameter/Scale", 1.9)
	($PanelContainer as Control).modulate.a = 0
	($PanelContainer as Control).offset_transform_position.y = 1000
	($PanelContainer as Control).offset_transform_scale = Vector2.ONE * .3

	if open_on_ready:
		animate_in()


func animate_in() -> Tween:
	($Audio as AudioStreamPlayer).play(0.)
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)

	get_tree().create_timer(.6).timeout.connect(func() -> void: animation_in_almost_ready.emit())

	tween.parallel().tween_property($PanelContainer as Control, "modulate:a", 1, .1)
	tween.parallel().tween_property($PanelContainer as Control, "offset_transform_position:y", 0, .75).from(1000)
	tween.parallel().tween_property(($SubViewport/ColorRect as ColorRect).material, "shader_parameter/Scale", 1, .33).set_delay(.5)
	tween.parallel().tween_property($PanelContainer as Control, "offset_transform_scale", Vector2.ONE, .33).set_delay(.5)
	return tween


func animate_out() -> Tween:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUART)

	get_tree().create_timer(.6).timeout.connect(func() -> void: animation_out_almost_ready.emit())

	tween.parallel().tween_property(($SubViewport/ColorRect as ColorRect).material, "shader_parameter/Scale", 1.9, .4)
	tween.parallel().tween_property($PanelContainer as Control, "modulate:a", 0., .2).set_delay(.2)
	tween.parallel().tween_property($PanelContainer as Control, "offset_transform_position:y", 1000, .2).set_delay(.2)
	return tween

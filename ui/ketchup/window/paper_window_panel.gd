class_name UiKetchupPaperWindowPanel
extends Control


func _ready() -> void:
	visible = false


func animate_out() -> void:
	var out_tween := create_tween()
	out_tween.tween_property(self, "offset_transform_position:x", 400., .4)
	out_tween.finished.connect(
		func() -> void:
			if not is_queued_for_deletion():
				queue_free()
	)


func animate_in(contents: Control, color := Color("#00161c")) -> void:
	var bg := $ColorRect as ColorRect
	self.visible = true

	bg.material.set("shader_parameter/ColorParameter", color)

	contents.set_anchors_and_offsets_preset(LayoutPreset.PRESET_FULL_RECT)
	contents.offset_left = 8.
	contents.offset_right = 0
	add_child(contents)

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, "offset_transform_position:x", 0., .4).from(400.)

	var bg_tween := create_tween()
	bg_tween.set_loops()
	bg_tween.set_parallel()
	bg_tween.tween_property(bg.material, "shader_parameter/MaskSlop", -1, 50.).from(0.)
	bg_tween.tween_property(bg.material, "shader_parameter/Bg_Scroll", 1, 80.).from(0.)

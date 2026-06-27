class_name UI_Settings
extends Control

# Window project settings:
#  - Stretch mode is set to `canvas_items` (`2d` in Godot 3.x)
#  - Stretch aspect is set to `expand`
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var fps_label: Label = $FPSLabel
@onready var resolution_label: Label = $ResolutionLabel

signal on_close

var counter := 0.0


func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		(%HideShowButton as Button).pressed.emit()


func _ready() -> void:
	($ButtonPrompts as UI_ButtonPrompts).push("ui_cancel")

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	find_next_valid_focus().grab_focus.call_deferred()

	($SubViewport/ColorRect as ColorRect).material.set("shader_parameter/Scale", 1.9)
	($PanelContainer as Control).set("offset_transform_scale", Vector2.ZERO)
	($PanelContainer as Control).modulate.a = 0
	($PanelContainer as Control).offset_transform_position.y = 500000

	tween.tween_property($PanelContainer as Control, "offset_transform_scale", Vector2.ONE, .5)
	tween.parallel().tween_property($PanelContainer as Control, "modulate:a", 1, .1)
	(
		tween
		. parallel()
		. tween_property($PanelContainer as Control, "offset_transform_position:y", 0, .75)
		. from(1000)
	)
	(
		tween
		. parallel()
		. tween_property(
			($SubViewport/ColorRect as ColorRect).material,
			"shader_parameter/Scale",
			1,
			.33,
		)
		. set_delay(.5)
	)

	get_viewport().size_changed.connect(update_resolution_label)
	update_resolution_label()
	(%ShadowSizeOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_int_setting(
			SavedData.Options.SHADOW_SIZE,
		)
	)
	(%ShadowFilterOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_int_setting(
			SavedData.Options.SHADOW_FILTER,
		)
	)
	(%MeshLODOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_int_setting(
			SavedData.Options.MESH_LOD,
		)
	)
	_connect_ui()
	SavedData.on_config_changed.connect(_connect_ui)


func _connect_ui() -> void:
	SavedData.apply_env_gfx_settings(world_environment)
	update_resolution_label()

	var viewport := get_viewport()
	if viewport != null:
		if get_viewport().scaling_3d_mode == Viewport.SCALING_3D_MODE_FSR:
			(%FSRSharpnessLabel as Control).visible = true
			(%FSRSharpnessSlider as Control).visible = true
		else:
			(%FSRSharpnessLabel as Control).visible = false
			(%FSRSharpnessSlider as Control).visible = false

	(%TAAOptionButton as OptionButton).selected = SavedData.get_gfx_setting(SavedData.Options.TAA)
	(%MSAAOptionButton as OptionButton).selected = SavedData.get_gfx_setting(SavedData.Options.MSAA)
	(%FXAAOptionButton as OptionButton).selected = SavedData.get_gfx_setting(SavedData.Options.FXAA)
	(%ShadowSizeOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.SHADOW_SIZE,
		)
	)
	(%ShadowFilterOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.SHADOW_FILTER,
		)
	)
	(%MeshLODOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.MESH_LOD,
		)
	)
	(%UIScaleOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.UI_SCALE,
		)
	)

	(%FullscreenOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.SCREEN_MODE,
		)
	)
	(%VsyncOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.VSYNC,
		)
	)
	(%FilterOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.SCALING_ALGO,
		)
	)

	(%QualitySlider as Slider).value = SavedData.get_gfx_setting(SavedData.Options.SCALING_SIZE)
	(%FSRSharpnessSlider as Slider).value = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.FSR_SHARPNESS,
		)
	)
	(%LimitFPSSlider as Slider).value = SavedData.get_gfx_setting(SavedData.Options.FPS_CAP)

	(%SSReflectionsOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.ENV_SS_REFLECTIONS,
		)
	)
	(%SSAOOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.ENV_SSAO,
		)
	)
	(%SSILOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.ENV_SSIL,
		)
	)
	(%SDFGIOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.ENV_SDFGI,
		)
	)
	(%GlowOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.ENV_GLOW,
		)
	)
	(%VolumetricFogOptionButton as OptionButton).selected = (
		SavedData
		. get_gfx_setting(
			SavedData.Options.ENV_FOG,
		)
	)


func _process(delta: float) -> void:
	counter += delta
	# Hide FPS label until it's initially updated by the engine (this can take up to 1 second).
	fps_label.visible = counter >= 1.0
	fps_label.text = (
		"%d FPS (%.2f mspf)"
		% [Engine.get_frames_per_second(), 1000.0 / Engine.get_frames_per_second()]
	)
	# Color FPS counter depending on framerate.
	# The Gradient resource is stored as metadata within the FPSLabel node (accessible in the inspector).
	var grad: Gradient = fps_label.get_meta("gradient")
	fps_label.modulate = grad.sample(remap(Engine.get_frames_per_second(), 0, 180, 0.0, 1.0))


func update_resolution_label() -> void:
	var viewport := get_viewport()
	if viewport == null:
		return

	@warning_ignore("unsafe_property_access")
	var viewport_render_size: Vector2 = viewport.size * viewport.scaling_3d_scale
	resolution_label.text = (
		"3D viewport resolution: %d × %d (%d%%)"
		% [viewport_render_size.x, viewport_render_size.y, round(viewport.scaling_3d_scale * 100)]
	)


func _on_ui_scale_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.UI_SCALE, index)


func _on_quality_slider_value_changed(value: float) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.SCALING_SIZE, value)


func _on_filter_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.SCALING_ALGO, index)


func _on_fsr_sharpness_slider_value_changed(value: float) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.FSR_SHARPNESS, value)


func _on_vsync_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.VSYNC, index)


func _on_limit_fps_slider_value_changed(value: float) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.FPS_CAP, value)


func _on_msaa_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.MSAA, index)


func _on_taa_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.TAA, index)


func _on_fxaa_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.FXAA, index)


func _on_fullscreen_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.SCREEN_MODE, index)


func _on_shadow_size_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.SHADOW_SIZE, index)


func _on_shadow_filter_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.SHADOW_FILTER, index)


func _on_mesh_lod_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.MESH_LOD, index)


func _on_ss_reflections_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.ENV_SS_REFLECTIONS, index)


func _on_ssao_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.ENV_SSAO, index)


func _on_ssil_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.ENV_SSIL, index)


func _on_sdfgi_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.ENV_SDFGI, index)


func _on_glow_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.ENV_GLOW, index)


func _on_volumetric_fog_option_button_item_selected(index: int) -> void:
	SavedData.apply_gfx_setting(SavedData.Options.ENV_FOG, index)


func _on_very_low_preset_pressed() -> void:
	SavedData.apply_gfx_preset(0)


func _on_low_preset_pressed() -> void:
	SavedData.apply_gfx_preset(1)


func _on_medium_preset_pressed() -> void:
	SavedData.apply_gfx_preset(2)


func _on_high_preset_pressed() -> void:
	SavedData.apply_gfx_preset(3)


func _on_ultra_preset_pressed() -> void:
	SavedData.apply_gfx_preset(4)


func _on_hide_show_button_pressed() -> void:
	on_close.emit()

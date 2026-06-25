extends Node

var config := ConfigFile.new()

@warning_ignore("unsafe_call_argument")
var viewport_start_size := Vector2(
	ProjectSettings.get_setting(&"display/window/size/viewport_width"),
	ProjectSettings.get_setting(&"display/window/size/viewport_height"),
)

enum Options {
	# globs
	TAA,
	MSAA,
	FXAA,
	SHADOW_SIZE,
	SHADOW_FILTER,
	MESH_LOD,
	UI_SCALE,

	# display
	SCREEN_MODE,
	VSYNC,
	SCALING_ALGO,
	SCALING_SIZE,
	FSR_SHARPNESS,
	FPS_CAP,

	# env
	ENV_SS_REFLECTIONS,
	ENV_SSAO,
	ENV_SSIL,
	ENV_SDFGI,
	ENV_GLOW,
	ENV_FOG,
}

var ENV_OPTIONS: Array[Options] = [
	Options.ENV_SS_REFLECTIONS,
	Options.ENV_SSAO,
	Options.ENV_SSIL,
	Options.ENV_SDFGI,
	Options.ENV_GLOW,
	Options.ENV_FOG,
]

var DISPLAY_OPTIONS: Array[Options] = [
	Options.SCREEN_MODE,
	Options.VSYNC,
	Options.SCALING_ALGO,
	Options.SCALING_SIZE,
	Options.FSR_SHARPNESS,
	Options.FPS_CAP,
]

signal on_config_changed


static func _get_default_gfx_settings() -> Dictionary[Options, Array]:
	return {
		Options.TAA: [0, 0, 1, 1, 1],
		Options.MSAA: [0, 0, 0, 0, 1],
		Options.FXAA: [0, 1, 0, 0, 0],
		Options.SHADOW_SIZE: [0, 1, 2, 3, 4],
		Options.SHADOW_FILTER: [0, 1, 2, 3, 4],
		Options.MESH_LOD: [0, 1, 1, 2, 3],
		Options.UI_SCALE: [1, 1, 1, 1, 1],
		Options.SCREEN_MODE: [0, 0, 0, 0, 0],
		Options.VSYNC: [0, 0, 0, 0, 0],
		Options.SCALING_ALGO: [0, 0, 0, 0, 0],
		Options.SCALING_SIZE: [1, 1, 1, 1, 1],
		Options.FSR_SHARPNESS: [0, 0, 0, 0, 0],
		Options.FPS_CAP: [30, 60, 60, 60, 60],
		Options.ENV_SDFGI: [0, 0, 1, 1, 2],
		Options.ENV_GLOW: [0, 0, 1, 2, 2],
		Options.ENV_SSAO: [0, 0, 1, 2, 3],
		Options.ENV_SS_REFLECTIONS: [0, 0, 1, 2, 3],
		Options.ENV_SSIL: [0, 0, 1, 2, 3],
		Options.ENV_FOG: [0, 0, 1, 2, 2],
	}


func _init() -> void:
	var err := config.load("user://gfx.cfg")

	if err != OK:
		printerr('oopsies')
		return


func _ready() -> void:
	for key in config.get_section_keys('gfx'):
		var value: Variant = config.get_value('gfx', key)
		@warning_ignore("unsafe_call_argument")
		apply_gfx_setting(int(key), value)


func get_gfx_setting(option: Options) -> Variant:
	return config.get_value(
		'gfx',
		str(option),
		_get_default_gfx_settings()[option][3],
	)


func get_gfx_int_setting(options: Options) -> int:
	@warning_ignore("unsafe_call_argument")
	return int(get_gfx_setting(options))


func apply_gfx_preset(preset: int) -> void:
	var values := _get_default_gfx_settings()
	for key: int in values.keys():
		if (!DISPLAY_OPTIONS.has(key)):
			_apply_gfx_setting_fast(key, values[key][preset])
	_save()


func apply_gfx_setting(option: Options, index: Variant) -> void:
	_apply_gfx_setting_fast(option, index)
	_save()


func _save() -> void:
	config.save("user://gfx.cfg")
	on_config_changed.emit()


func _apply_gfx_setting_fast(option: Options, index: Variant) -> void:
	config.set_value('gfx', str(option), index)

	match option:
		Options.SHADOW_SIZE:
			if index == 0: # Minimum
				RenderingServer.directional_shadow_atlas_set_size(512, true)
				# Adjust shadow bias according to shadow resolution.
				# Higher resultions can use a lower bias without suffering from shadow acne.

				# Disable positional (omni/spot) light shadows entirely to further improve performance.
				# These often don't contribute as much to a scene compared to directional light shadows.
				get_viewport().positional_shadow_atlas_size = 0
			if index == 1: # Very Low
				RenderingServer.directional_shadow_atlas_set_size(1024, true)
				get_viewport().positional_shadow_atlas_size = 1024
			if index == 2: # Low
				RenderingServer.directional_shadow_atlas_set_size(2048, true)
				get_viewport().positional_shadow_atlas_size = 2048
			if index == 3: # Medium (default)
				RenderingServer.directional_shadow_atlas_set_size(4096, true)
				get_viewport().positional_shadow_atlas_size = 4096
			if index == 4: # High
				RenderingServer.directional_shadow_atlas_set_size(8192, true)
				get_viewport().positional_shadow_atlas_size = 8192
			if index == 5: # Ultra
				RenderingServer.directional_shadow_atlas_set_size(16384, true)
				get_viewport().positional_shadow_atlas_size = 16384
		Options.SHADOW_FILTER:
			if index == 0: # Very Low
				RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
				RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
			if index == 1: # Low
				RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
				RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
			if index == 2: # Medium (default)
				RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
				RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
			if index == 3: # High
				RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
				RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
			if index == 4: # Very High
				RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
				RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
			if index == 5: # Ultra
				RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
				RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
		Options.MESH_LOD:
			if index == 0: # Very Low
				get_viewport().mesh_lod_threshold = 8.0
			if index == 0: # Low
				get_viewport().mesh_lod_threshold = 4.0
			if index == 1: # Medium
				get_viewport().mesh_lod_threshold = 2.0
			if index == 2: # High (default)
				get_viewport().mesh_lod_threshold = 1.0
			if index == 3: # Ultra
				# Always use highest LODs to avoid any form of pop-in.
				get_viewport().mesh_lod_threshold = 0.0
		Options.UI_SCALE:
			var new_size := viewport_start_size
			if index == 0: # Small (80%)
				new_size *= 1.25
			elif index == 1: # Medium (100%) (default)
				new_size *= 1.0
			elif index == 2: # Large (133%)
				new_size *= 0.75
			get_tree().root.set_content_scale_size(new_size)
		Options.SCREEN_MODE:
			# To change between winow, fullscreen and other window modes,
			# set the root mode to one of the options of Window.MODE_*.
			# Other modes are maximized and minimized.
			if index == 0: # Disabled (default)
				get_tree().root.set_mode(Window.MODE_WINDOWED)
			elif index == 1: # Fullscreen
				get_tree().root.set_mode(Window.MODE_FULLSCREEN)
			elif index == 2: # Exclusive Fullscreen
				get_tree().root.set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)
		Options.FXAA:
			# Fast approximate anti-aliasing. Much faster than MSAA (and works on alpha scissor edges),
			# but blurs the whole scene rendering slightly.
			@warning_ignore("unsafe_call_argument")
			get_viewport().screen_space_aa = int(index == 1) as Viewport.ScreenSpaceAA
		Options.TAA:
			# Temporal antialiasing. Smooths out everything including specular aliasing, but can introduce
			# ghosting artifacts and blurring in motion. Moderate performance cost.
			get_viewport().use_taa = index == 1
		Options.MSAA:
			# Multi-sample anti-aliasing. High quality, but slow. It also does not smooth out the edges of
			# transparent (alpha scissor) textures.
			if index == 0: # Disabled (default)
				get_viewport().msaa_3d = Viewport.MSAA_DISABLED
			elif index == 1: # 2×
				get_viewport().msaa_3d = Viewport.MSAA_2X
			elif index == 2: # 4×
				get_viewport().msaa_3d = Viewport.MSAA_4X
			elif index == 3: # 8×
				get_viewport().msaa_3d = Viewport.MSAA_8X
		Options.FPS_CAP:
			var value: float = index
			# The maximum number of frames per second that can be rendered.
			# A value of 0 means "no limit".
			print(value, int(value))
			Engine.max_fps = int(value)
		Options.VSYNC:
			if index == 0: # Disabled (default)
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
			elif index == 1: # Adaptive
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
			elif index == 2: # Enabled
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		Options.FSR_SHARPNESS:
			var value: float = index
			get_viewport().fsr_sharpness = 2.0 - value
		Options.SCALING_ALGO:
			if index == 0: # Bilinear (Fastest)
				get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
			elif index == 1: # FSR 1.0 (Fast)
				get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
		Options.SCALING_SIZE:
			var value: float = index
			print(value)
			get_viewport().scaling_3d_scale = value
	_save()


func apply_env_gfx_settings(world_environment: WorldEnvironment) -> void:
	for option_key in ENV_OPTIONS:
		var value: int = get_gfx_setting(option_key)
		apply_env_gfx_setting(world_environment, option_key, value)


func apply_env_gfx_setting(world_environment: WorldEnvironment, option: Options, index: int) -> void:
	match option:
		Options.ENV_SS_REFLECTIONS:
			# This is a setting that is attached to the environment.
			# If your game requires you to change the environment,
			# then be sure to run this function again to make the setting effective.
			if index == 0: # Disabled (default)
				world_environment.environment.set_ssr_enabled(false)
			elif index == 1: # Low
				world_environment.environment.set_ssr_enabled(true)
				world_environment.environment.set_ssr_max_steps(8)
			elif index == 2: # Medium
				world_environment.environment.set_ssr_enabled(true)
				world_environment.environment.set_ssr_max_steps(32)
			elif index == 3: # High
				world_environment.environment.set_ssr_enabled(true)
				world_environment.environment.set_ssr_max_steps(56)
		Options.ENV_SSAO:
			# This is a setting that is attached to the environment.
			# If your game requires you to change the environment,
			# then be sure to run this function again to make the setting effective.
			if index == 0: # Disabled (default)
				world_environment.environment.ssao_enabled = false
			if index == 1: # Very Low
				world_environment.environment.ssao_enabled = true
				RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
			if index == 2: # Low
				world_environment.environment.ssao_enabled = true
				RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
			if index == 3: # Medium
				world_environment.environment.ssao_enabled = true
				RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
			if index == 4: # High
				world_environment.environment.ssao_enabled = true
				RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 2, 50, 300)
		Options.ENV_SSIL:
			# This is a setting that is attached to the environment.
			# If your game requires you to change the environment,
			# then be sure to run this function again to make the setting effective.
			if index == 0: # Disabled (default)
				world_environment.environment.ssil_enabled = false
			if index == 1: # Very Low
				world_environment.environment.ssil_enabled = true
				RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_VERY_LOW, true, 0.5, 4, 50, 300)
			if index == 2: # Low
				world_environment.environment.ssil_enabled = true
				RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_LOW, true, 0.5, 4, 50, 300)
			if index == 3: # Medium
				world_environment.environment.ssil_enabled = true
				RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_MEDIUM, true, 0.5, 4, 50, 300)
			if index == 4: # High
				world_environment.environment.ssil_enabled = true
				RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_HIGH, true, 0.5, 4, 50, 300)
		Options.ENV_SDFGI:
			# This is a setting that is attached to the environment.
			# If your game requires you to change the environment,
			# then be sure to run this function again to make the setting effective.
			if index == 0: # Disabled (default)
				world_environment.environment.sdfgi_enabled = false
			if index == 1: # Low
				world_environment.environment.sdfgi_enabled = true
				RenderingServer.gi_set_use_half_resolution(true)
			if index == 2: # High
				world_environment.environment.sdfgi_enabled = true
				RenderingServer.gi_set_use_half_resolution(false)
		Options.ENV_GLOW:
			# This is a setting that is attached to the environment.
			# If your game requires you to change the environment,
			# then be sure to run this function again to make the setting effective.
			if index == 0: # Disabled (default)
				world_environment.environment.glow_enabled = false
			if index == 1: # Low
				world_environment.environment.glow_enabled = true
			if index == 2: # High
				world_environment.environment.glow_enabled = true
		Options.ENV_FOG:
			if index == 0: # Disabled (default)
				world_environment.environment.volumetric_fog_enabled = false
			if index == 1: # Low
				world_environment.environment.volumetric_fog_enabled = true
				RenderingServer.environment_set_volumetric_fog_filter_active(false)
			if index == 2: # High
				world_environment.environment.volumetric_fog_enabled = true
				RenderingServer.environment_set_volumetric_fog_filter_active(true)

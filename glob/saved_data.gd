extends Node

var config := ConfigFile.new()

@warning_ignore("unsafe_call_argument")
var viewport_start_size := Vector2(
	ProjectSettings.get_setting(&"display/window/size/viewport_width"),
	ProjectSettings.get_setting(&"display/window/size/viewport_height"),
)

enum Options {
	SHADOW_SIZE,
	SHADOW_FILTER,
	MESH_LOD,
}

static func _get_default_gfx_settings(preset:=3) -> Dictionary[Options, int]:
	return {
		Options.SHADOW_SIZE: 2,
		Options.SHADOW_FILTER: 2,
		Options.MESH_LOD: 1
	}


func _init() -> void:
	var err := config.load("user://gfx.cfg")
	if err != OK:
		printerr('oopsies')
		return


func _ready() -> void:
	for key in config.get_section_keys('gfx'):
		@warning_ignore("unsafe_cast")
		apply_gfx_int_setting(int(key), type_convert(config.get_value('gfx', key), TYPE_INT) as int)

func get_gfx_int_setting(option: Options) -> int:
	var value : int = config.get_value('gfx', str(option))
	if(value != null):
		return value
	return _get_default_gfx_settings()[option]


func apply_gfx_int_setting(option: Options, index: int) -> void:
	config.set_value('gfx', str(option), index)
	config.save("user://gfx.cfg")
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

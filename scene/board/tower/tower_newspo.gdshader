// NOTE: Shader automatically converted from Godot Engine 4.7.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec3 base_color : source_color = vec3(1.0);
uniform sampler2D texture_albedo : source_color, filter_nearest_mipmap;

uniform bool flip = false;

void fragment() {
	vec2 base_uv = UV;
	
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	
	ALBEDO = (base_color * albedo_tex.rgb);
	if(flip){
		vec3 flipped = vec3(.8,.8,.8) - albedo_tex.rgb;
		ALBEDO = max(base_color, flipped);
	}
	

	METALLIC = 0.0;
	SPECULAR = 0.0;
	ROUGHNESS = 0.0;
}

// lava_ground.gdshader
// شيدر أرض الحمم المتدفقة - Lava Ground Shader (العالم 6)

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D noise_texture : hint_default_white;
uniform vec4 lava_color_hot : source_color = vec4(1.0, 0.4, 0.0, 1.0);
uniform vec4 lava_color_cool : source_color = vec4(0.15, 0.0, 0.0, 1.0);
uniform float flow_speed : hint_range(0.0, 2.0) = 0.3;
uniform float emission_strength : hint_range(0.0, 10.0) = 3.0;

void fragment() {
	vec2 uv = UV;
	float time = TIME * flow_speed;
	
	// حركة الحمم (طبقتان)
	vec2 flow_uv1 = uv + vec2(time * 0.2, time * 0.1);
	vec2 flow_uv2 = uv - vec2(time * 0.15, time * 0.05);
	
	float noise1 = texture(noise_texture, flow_uv1).r;
	float noise2 = texture(noise_texture, flow_uv2 * 1.5).r;
	float combined_noise = (noise1 + noise2) * 0.5;
	
	// مزج الألوان
	float heat = smoothstep(0.3, 0.8, combined_noise);
	ALBEDO = mix(lava_color_cool.rgb, lava_color_hot.rgb, heat);
	
	// Emission للحمم الساخنة
	EMISSION = lava_color_hot.rgb * heat * emission_strength;
	
	// لا بريق على الحمم الباردة، بريق على الساخنة
	ROUGHNESS = 1.0 - heat * 0.5;
	METALLIC = 0.0;
	
	// تأثير التوهج الحراري
	float glow_pulse = sin(TIME * 2.0 + combined_noise * 10.0) * 0.5 + 0.5;
	EMISSION += lava_color_hot.rgb * glow_pulse * 0.5 * heat;
}

// ============================================================

// water_atlantis.gdshader
// شيدر مياه أتلانتس الغارقة - Atlantis Water Shader (العالم 7)

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D water_normal_1 : hint_roughness_normal;
uniform sampler2D water_normal_2 : hint_roughness_normal;
uniform vec4 water_color : source_color = vec4(0.0, 0.4, 0.6, 0.85);
uniform float wave_speed : hint_range(0.0, 3.0) = 0.8;
uniform float wave_strength : hint_range(0.0, 1.0) = 0.15;
uniform float reflection_strength : hint_range(0.0, 1.0) = 0.6;
uniform float depth_fade : hint_range(0.0, 10.0) = 3.0;

void vertex() {
	float time = TIME * wave_speed;
	// تموج السطح
	float wave1 = sin(VERTEX.x * 2.0 + time) * wave_strength * 0.1;
	float wave2 = cos(VERTEX.z * 1.5 + time * 0.8) * wave_strength * 0.08;
	VERTEX.y += wave1 + wave2;
}

void fragment() {
	float time = TIME * wave_speed;
	
	// طبقتا Normal للموجات
	vec3 n1 = texture(water_normal_1, UV + vec2(time * 0.1, time * 0.05)).rgb * 2.0 - 1.0;
	vec3 n2 = texture(water_normal_2, UV - vec2(time * 0.08, time * 0.06)).rgb * 2.0 - 1.0;
	vec3 normal = normalize(n1 + n2);
	
	ALBEDO = water_color.rgb;
	ALPHA = water_color.a;
	NORMAL_MAP = normal * 0.5 + 0.5;
	ROUGHNESS = 0.05;
	METALLIC = 0.1;
	
	// تأثير عمق الماء
	float depth_factor = smoothstep(0.0, depth_fade, FRAGCOORD.z);
	ALBEDO *= mix(vec3(0.0, 0.5, 0.7), vec3(0.0, 0.2, 0.4), depth_factor);
	
	// تأثير Rim Lighting للحواف
	float rim = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	EMISSION = vec3(0.0, 0.5, 0.8) * pow(rim, 3.0) * 0.5;
}

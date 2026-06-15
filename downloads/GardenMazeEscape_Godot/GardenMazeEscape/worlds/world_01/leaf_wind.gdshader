// leaf_wind.gdshader
// شيدر حركة الأوراق بتأثير الريح - Leaf Wind Vertex Shader
// يُطبَّق على أشجار المتاهة لإعطاء إحساس الحياة

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// ============================
// UNIFORMS / المتغيرات الموحدة
// ============================
uniform vec4 albedo_color : source_color = vec4(0.3, 0.7, 0.2, 1.0);
uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform sampler2D normal_map : hint_roughness_normal, hint_default_flat;
uniform sampler2D roughness_map : hint_roughness_r;
uniform sampler2D ao_map : hint_default_white;

uniform float wind_strength : hint_range(0.0, 2.0) = 0.3;
uniform float wind_speed : hint_range(0.0, 5.0) = 1.2;
uniform float wind_direction : hint_range(0.0, 6.28) = 0.7;
uniform float sway_intensity : hint_range(0.0, 1.0) = 0.15;

uniform float roughness : hint_range(0.0, 1.0) = 0.7;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;

// ============================
// VERTEX SHADER / شيدر الرأس
// ============================
void vertex() {
	// الوقت
	float time = TIME * wind_speed;
	
	// اتجاه الريح
	vec2 wind_dir = vec2(cos(wind_direction), sin(wind_direction));
	
	// تأثير التأرجح بناءً على الارتفاع (Y)
	// الأجزاء العليا تتأثر أكثر من القاعدة
	float height_factor = max(0.0, VERTEX.y / 4.0);
	
	// موجة الريح الرئيسية
	float wind_wave = sin(time + VERTEX.x * 0.5 + VERTEX.z * 0.5) * wind_strength;
	
	// موجة صغيرة سريعة (رجفة أوراق)
	float leaf_flutter = sin(time * 3.7 + VERTEX.x * 2.0) * 0.05;
	
	// موجة ثانوية لحركة أكثر طبيعية
	float secondary_wave = cos(time * 0.7 + VERTEX.z * 0.3) * 0.5;
	
	// إجمالي الحركة الأفقية
	float total_sway = (wind_wave + secondary_wave * 0.3) * sway_intensity * height_factor;
	float flutter_y = sin(time * 5.0 + VERTEX.x) * 0.02 * height_factor;
	
	// تطبيق الحركة على الرأس
	VERTEX.x += wind_dir.x * total_sway + leaf_flutter * height_factor;
	VERTEX.z += wind_dir.y * total_sway;
	VERTEX.y += flutter_y;
}

// ============================
// FRAGMENT SHADER / شيدر الجزء
// ============================
void fragment() {
	vec4 tex_color = texture(albedo_texture, UV);
	ALBEDO = albedo_color.rgb * tex_color.rgb;
	ALPHA = albedo_color.a * tex_color.a;
	
	// Normal Map
	NORMAL_MAP = texture(normal_map, UV).rgb;
	NORMAL_MAP_DEPTH = 1.5;
	
	// Roughness
	ROUGHNESS = roughness * texture(roughness_map, UV).r;
	
	// Metallic
	METALLIC = metallic;
	
	// Ambient Occlusion
	AO = texture(ao_map, UV).r;
	AO_LIGHT_AFFECT = 0.5;
	
	// تأثير Subsurface Scattering للأوراق
	// يجعل الضوء ينفذ عبر الأوراق كما في الطبيعة
	SSS_STRENGTH = 0.3;
}

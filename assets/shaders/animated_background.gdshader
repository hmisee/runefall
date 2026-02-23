shader_type canvas_item;

// Shader parameters that can be configured from code
uniform float time_scale : hint_range(0.1, 5.0) = 1.0;
uniform vec4 color_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float wave_amplitude : hint_range(0.0, 1.0) = 0.1;
uniform float wave_frequency : hint_range(0.1, 10.0) = 2.0;
uniform float rotation_speed : hint_range(-2.0, 2.0) = 0.5;
uniform sampler2D base_texture : hint_default_white;

void fragment() {
	// Get time with configurable scale
	float t = TIME * time_scale;
	
	// Apply rotation effect
	vec2 center = vec2(0.5, 0.5);
	vec2 uv = UV - center;
	float angle = t * rotation_speed;
	float cos_angle = cos(angle);
	float sin_angle = sin(angle);
	vec2 rotated_uv = vec2(
		uv.x * cos_angle - uv.y * sin_angle,
		uv.x * sin_angle + uv.y * cos_angle
	) + center;
	
	// Apply wave distortion
	rotated_uv.x += sin(rotated_uv.y * wave_frequency + t) * wave_amplitude;
	rotated_uv.y += cos(rotated_uv.x * wave_frequency + t) * wave_amplitude;
	
	// Sample texture with transformed UV
	vec4 tex_color = texture(base_texture, rotated_uv);
	
	// Apply color tint
	COLOR = tex_color * color_tint;
}

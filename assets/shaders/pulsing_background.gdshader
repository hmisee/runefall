shader_type canvas_item;

// Shader parameters that can be configured from code
uniform float pulse_speed : hint_range(0.1, 5.0) = 1.0;
uniform float pulse_intensity : hint_range(0.0, 1.0) = 0.3;
uniform vec4 pulse_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D base_texture : hint_default_white;

void fragment() {
	// Calculate pulsing effect using sine wave
	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
	float brightness = 1.0 + (pulse * pulse_intensity);
	
	// Sample base texture
	vec4 tex_color = texture(base_texture, UV);
	
	// Apply pulsing brightness and color tint
	COLOR = tex_color * pulse_color * brightness;
}

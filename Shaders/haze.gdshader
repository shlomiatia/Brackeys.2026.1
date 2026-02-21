shader_type canvas_item;

uniform float speed : hint_range(0.0, 2.0) = 0.25;
uniform float intensity : hint_range(0.0, 0.05) = 0.007;

void fragment() {
	float t = TIME * speed;

	// Two overlapping sine waves at different frequencies for an organic haze
	vec2 distortion = vec2(
		sin(UV.y * 9.0 + t * 1.4) * cos(UV.x * 5.0 + t * 0.6),
		cos(UV.x * 7.0 + t * 0.8) * sin(UV.y * 4.0 + t * 1.2)
	) * intensity;

	COLOR = texture(TEXTURE, UV + distortion);
}

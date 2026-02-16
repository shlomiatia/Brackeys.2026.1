shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.2, 0.2, 0.2, 0.5);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(shadow_color.rgb, tex.a * shadow_color.a);
}

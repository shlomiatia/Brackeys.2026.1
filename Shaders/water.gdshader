shader_type canvas_item;

uniform vec4 color1 : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color2 : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color3 : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color4 : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 bg_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec2 direction = vec2(1.0, 0.0);
uniform float max_distance : hint_range(0.0, 100.0) = 10.0;
uniform float pixels_per_second : hint_range(0.1, 100.0) = 5.0;
uniform float custom_time = -1.0;
uniform float current_offset = 0.0;

bool colors_match(vec4 a, vec4 b) {
    return distance(a, b) < 0.01;
}

void fragment() {
    //float time = custom_time;
    //if (time == -1.0) {
        //time = TIME;
    //}
    vec2 norm_direction = normalize(direction);
//
    //float time_in_cycle = mod(floor(time * pixels_per_second), max_distance * 2.0);
    //float current_offset;
//
    //if (time_in_cycle < max_distance) {
        //current_offset = time_in_cycle;
    //} else {
        //current_offset = max_distance * 2.0 - time_in_cycle;
    //}
    
    vec2 source_uv = UV - norm_direction * current_offset * TEXTURE_PIXEL_SIZE;
    vec4 src_color = texture(TEXTURE, source_uv);
    vec4 current_color = texture(TEXTURE, UV);

    if (colors_match(src_color, color1)) {
        COLOR = color1;
    } else if (colors_match(src_color, color2)) {
        COLOR = color2;
    } else if (colors_match(src_color, color3)) {
        COLOR = color3;
    } else if (colors_match(src_color, color4)) {
        COLOR = color4;
    } else if (colors_match(current_color, color1) ||
               colors_match(current_color, color2) || 
               colors_match(current_color, color3) || 
               colors_match(current_color, color4)) {
        COLOR = bg_color;
    }
}
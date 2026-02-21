shader_type canvas_item;

uniform vec4 color1 : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color2 : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color3 : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color4 : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 bg_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
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
    float tile_height_uv = 17.0 * TEXTURE_PIXEL_SIZE.y;
    if (UV.y <= tile_height_uv) {
        float source_y = UV.y - mod(current_offset, 16) * TEXTURE_PIXEL_SIZE.y;
        if (source_y < 0.0) {
            source_y = 16.0 * TEXTURE_PIXEL_SIZE.y + source_y;
        }
        vec2 source_uv = vec2(UV.x, source_y);
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
}
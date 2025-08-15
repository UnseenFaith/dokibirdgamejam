shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0; // 0 = invisible, 1 = visible

// 4x4 Bayer matrix pattern for dithering
const float bayer4x4[16] = float[16](
     0.0,  8.0,  2.0, 10.0,
    12.0,  4.0, 14.0,  6.0,
     3.0, 11.0,  1.0,  9.0,
    15.0,  7.0, 13.0,  5.0
);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Get pixel coordinates in integers
    ivec2 pixel_coords = ivec2(FRAGCOORD.xy);

    // Find Bayer matrix value for this pixel
    int index = (pixel_coords.y % 4) * 4 + (pixel_coords.x % 4);
    float threshold = (bayer4x4[index] + 0.5) / 16.0; // normalize 0..1

    // Show pixel only if progress is greater than threshold
    if (progress < threshold) {
        discard;
    }

    COLOR = tex_color;
}

shader_type canvas_item;

// --- Transition Parameters ---
uniform float progress : hint_range(0.0, 1.0) = 0.0; // 0 = start, 1 = fully white
uniform float swirl_strength : hint_range(0.0, 50.0) = 20.0; // swirl intensity
uniform vec2 center = vec2(0.5, 0.5); // pivot of the swirl
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 offset = uv - center;

    float radius = length(offset);
    float angle = atan(offset.y, offset.x);

    // Apply swirl scaled by radius and progress
    float swirl_angle = progress * swirl_strength * radius;
    angle += swirl_angle;

    // Collapse toward center
    float scale = 1.0 - progress;
    offset = vec2(cos(angle), sin(angle)) * radius * scale;

    // Reconstruct UVs
    vec2 new_uv = center + offset;

    // Base colors
    vec4 black = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 white = vec4(1.0, 1.0, 1.0, 1.0);

    // If UV is outside [0,1], use black; otherwise sample the screen
	vec4 tex_color = (new_uv.x < 0.0 || new_uv.x > 1.0 || new_uv.y < 0.0 || new_uv.y > 1.0) 
    	? vec4(1.0, 1.0, 1.0, 1.0)  // use white instead of black
    	: texture(SCREEN_TEXTURE, new_uv);

    // Mix screen color with white based on progress
    COLOR = mix(tex_color, white, progress);
}

shader_type canvas_item;

// 0 = screen fully on, 1 = fully off
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 center = vec2(0.5, 0.5); // collapse point
uniform float glow_strength : hint_range(0.0, 2.0) = 1.0;
uniform float static_strength : hint_range(0.0, 0.5) = 0.15;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    vec2 dir = uv - center;

    // Collapse vertically first (0 → 0.5)
    float vertical_scale = mix(1.0, 0.0, smoothstep(0.0, 0.5, progress));
    dir.y *= vertical_scale;

    // Collapse horizontally after vertical collapse (0.5 → 1.0)
    float horizontal_scale = mix(1.0, 0.0, smoothstep(0.5, 1.0, progress));
    dir.x *= horizontal_scale;

    vec2 distorted_uv = center + dir;

    // Sample texture with RGB separation for vintage feel
    vec4 tex_color = vec4(0.0);
    if (distorted_uv.x >= 0.0 && distorted_uv.x <= 1.0 &&
        distorted_uv.y >= 0.0 && distorted_uv.y <= 1.0) {
        float offset = 0.002; // small RGB shift
        float r = texture(TEXTURE, distorted_uv + vec2(offset, 0.0)).r;
        float g = texture(TEXTURE, distorted_uv).g;
        float b = texture(TEXTURE, distorted_uv - vec2(offset, 0.0)).b;
        tex_color = vec4(r, g, b, 1.0);
    }

    // Add white glow at center during collapse
    float dist_to_center = length(uv - center);
    float glow = exp(-dist_to_center * 40.0) * glow_strength;
    glow *= smoothstep(0.0, 1.0, progress) * (1.0 - progress + 0.3);

    // Add faint static during collapse
    float noise = random(uv * (TIME * 50.0)) - 0.5;
    noise *= static_strength * smoothstep(0.0, 1.0, progress);

    // Fade brightness with progress
    float fade = 1.0 - progress;

    COLOR = tex_color * fade + vec4(vec3(glow + noise), 1.0);
}

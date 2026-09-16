// Original display-referred grade; no LUT, copied filmic curve, or auto exposure.
vec3 blohoGrade(vec3 inputColor, vec2 uv) {
    vec3 color = max(inputColor, vec3(0.0)) * EXPOSURE;
    color *= vec3(1.0 + COLOR_WARMTH * 0.12, 1.0, 1.0 - COLOR_WARMTH * 0.1);
    // Compress highlight magnitude while retaining channel ratios.
    float peak = max(color.r, max(color.g, color.b));
    if (peak > 0.72) {
        float excess = peak - 0.72;
        float shoulder = 0.72 + 0.28 * excess / (excess + 0.28);
        color *= shoulder / peak;
    }
    float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
    color = mix(vec3(brightness), color, SATURATION);
    color = clamp(color, 0.0, 1.0);
    // Smooth contrast pivot keeps black and white anchored.
    color += (CONTRAST - 1.0) * 4.0 * (color - 0.5) * color * (1.0 - color);
    vec2 centered = uv * 2.0 - 1.0;
    float edge = smoothstep(0.35, 1.6, dot(centered, centered));
    color *= 1.0 - VIGNETTE_STRENGTH * edge;
    return clamp(color, 0.0, 1.0);
}


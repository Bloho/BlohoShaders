float blohoOreMask(vec3 texel, float id) {
    float peak = max(texel.r, max(texel.g, texel.b));
    float minimum = min(texel.r, min(texel.g, texel.b));
    float chroma = peak - minimum;
    float colored = smoothstep(0.12, 0.4, chroma / max(peak, 0.001));
    if (abs(id - 16.0) < 0.25 || abs(id - 18.0) < 0.25) {
        // Colored Overworld veins; neutral stone/deepslate is rejected.
        return colored * smoothstep(0.12, 0.4, peak);
    }
    if (abs(id - 17.0) < 0.25) {
        // Iron's warm, low-saturation inclusions need their own mask.
        return smoothstep(0.025, 0.1, texel.r - texel.b)
             * smoothstep(0.0, 0.04, texel.r - texel.g);
    }
    if (abs(id - 19.0) < 0.25) {
        // Yellow gold flecks, without lighting up red netherrack.
        return smoothstep(0.07, 0.2, texel.g - texel.b)
             * smoothstep(0.25, 0.6, texel.g);
    }
    if (abs(id - 20.0) < 0.25) {
        return smoothstep(0.42, 0.7, minimum);
    }
#if NEUTRAL_ORE_GLOW == 1
    if (abs(id - 21.0) < 0.25) {
        // this should stop glowing of the host blocks tho
        return (1.0 - smoothstep(0.1, 0.25, peak))
             * (1.0 - smoothstep(0.04, 0.15, chroma));
    }
    if (abs(id - 22.0) < 0.25) {
        return smoothstep(0.5, 0.75, texel.g / max(texel.r, 0.001));
    }
#endif
    return 0.0;
}

vec3 blohoOreEmission(vec3 lit, vec3 surface, vec3 rawTexel, float id) {
    if (id < 15.5 || id > 22.5 || ORE_GLOW_STRENGTH <= 0.0) return lit;
    float mask = blohoOreMask(rawTexel, id);
    float peak = max(rawTexel.r, max(rawTexel.g, rawTexel.b));
    vec3 emission = surface / max(peak, 0.02) * (1.0 + ORE_GLOW_STRENGTH);
#if NEUTRAL_ORE_GLOW == 1
    if (abs(id - 21.0) < 0.25) {
        emission = vec3(0.55, 0.64, 0.75) * (1.0 + ORE_GLOW_STRENGTH);
    }
#endif
    return max(lit, emission * mask);
}

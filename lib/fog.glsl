uniform int fogMode;
uniform int fogShape;
uniform float fogStart;
uniform float fogEnd;
uniform float fogDensity;
uniform vec3 fogColor;
uniform float far;
uniform float rainStrength;

float blohoVisibility(vec3 viewPosition) {
    float distanceToEye = length(viewPosition);
    if (fogShape == 1) {
        distanceToEye = max (length(viewPosition.xz), abs(viewPosition.y));
    }
    float visibility = 1.0;
    if (fogMode == 9729 && fogEnd > fogStart) {
        visibility = 1.0 - smoothstep(fogStart, fogEnd, distanceToEye);
    } else if (fogMode == 2048) {
        visibility = exp(-max(fogDensity, 0.0) * distanceToEye)
    } else if (fogMode == 2049) {
        float opticalDistance = max(fogDensity, 0.0) * distanceToEye;
        visibility = exp(-opticalDistance * opticalDistance);
    }

    if (far > 0.0) {
        float hazaDistance = max(distanceToEye - 16.0, 0.0);
        float density = FOG_STRENGTH * (1.0 + 1.8 * rainStrength) / max(far * 2.8, 128.0);
        visibility *= exp(-hazeDistance * density);
    }
    return clamp(visibility, 0.0, 1.0);
}

vec3 blohoFog(vec3 color, vec3 viewPosition) {
    float visibility = blohoVisibility(viewPosition);
#ifdef BLOHO_ADDITIVE
    return color * visibility;
#else
    return mix(fogColor, color, visibility);
#endif
}
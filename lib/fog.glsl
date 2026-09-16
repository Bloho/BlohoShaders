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
    } else if ()
}
#include "/settings.glsl"
uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;
varying vec2 screenUV;

vec3 blohoHighlight(vec2 uv) {
    vec3 color = texture2D(colortex0, clamp(uv, vec2(0.0), vec2(1.0))).rgb;
    float peak = max(color.r, max(color.g, color.b));
    float contribution = smoothstep(BLOOM_THRESHOLD - 0.1, BLOOM_THRESHOLD + 0.1, peak);
    return color * contribution;
}

void main() {
    vec3 highlight = vec3(0.0);
#if BLOHO_BLOOM == 1
    // Threshold before downsampling so small bright sources remain represented.
    vec2 offset = 0.5 / max(vec2(viewWidth, viewHeight), vec2(1.0));
    highlight = (blohoHighlight(screenUV + offset) + blohoHighlight(screenUV - offset)
               + blohoHighlight(screenUV + vec2(offset.x, -offset.y))
               + blohoHighlight(screenUV + vec2(-offset.x, offset.y))) * 0.25;
#endif
    gl_FragData[0] = vec4(highlight, 1.0);
}


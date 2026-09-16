#include "/settings.glsl"
#ifdef BLOHO_BLUR_HORIZONTAL
uniform sampler2D colortex4;
#else
uniform sampler2D colortex5;
#endif
uniform float viewWidth;
uniform float viewHeight;
varying vec2 screenUV;

void main() {
    vec3 blurred = vec3(0.0);
#if BLOHO_BLOOM == 1
    vec2 bloomSize = max(floor(vec2(viewWidth, viewHeight) * 0.5), vec2(1.0));
#ifdef BLOHO_BLUR_HORIZONTAL
    vec2 direction = vec2(BLOOM_RADIUS / bloomSize.x, 0.0);
#else
    vec2 direction = vec2(0.0, BLOOM_RADIUS / bloomSize.y);
#endif
    // triangular kernels, applied to each axis of an image
    for (int tap = -4; tap <= 4; ++tap) {
        float weight = 5.0 - abs(float(tap));
        vec2 uv = clamp(screenUV + direction * float(tap), 0.5 / bloomSize, 1.0 - 0.5 / bloomSize);
#ifdef BLOHO_BLUR_HORIZONTAL
        blurred += texture2D(colortex4, uv).rgb * weight;
#else
        blurred += texture2D(colortex5, uv).rgb * weight;
#endif
    }
    blurred /= 25.0;
#endif
    gl_FragData[0] = vec4(blurred, 1.0);
}

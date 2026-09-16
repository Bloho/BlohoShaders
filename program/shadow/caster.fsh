#include "/settings.glsl"
#include "/lib/shadow_config.glsl"
uniform sampler2D gtexture;
varying vec2 shadowUV;
varying vec4 shadowTint;
varying float shadowMaterial;

void main() {
    vec4 surface = texture2D(gtexture, shadowUV) * shadowTint;
    // so this is basically leaf holes
    if (surface.a < 0.5 || abs(shadowMaterial - 1.0) < 0.25 || abs(shadowMaterial - 4.0) < 0.25) discard;
    gl_FragData[0] = vec4(1.0);
}


#include "/lib/shadow_config.glsl"
uniform sampler2D shadowtex0;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

float blohoShadow(vec3 scenePosition, vec3 worldNormal) {
    float texel = 1.0 / float(shadowMapResolution);
    vec3 biasedPosition = scenePosition + worldNormal * (shadowDistance * texel);
    vec4 lightClip = shadowProjection * shadowModelView * vec4(biasedPosition, 1.0);
    if (abs(lightClip.w) < 0.000001) return 1.0;
    vec3 uvDepth = lightClip.xyz / lightClip.w * 0.5 + 0.5;
    if (uvDepth.z <= 0.0 || uvDepth.z >= 1.0 ||
        min(uvDepth.x, uvDepth.y) < 2.0 * texel || max(uvDepth.x, uvDepth.y) > 1.0 - 2.0 * texel) return 1.0;
 
    vec3 lightNormal = mat3(shadowModelView) * worldNormal;
    if (abs(lightNormal.z) < 0.0001) return 1.0;
    vec2 depthGradient = -lightNormal.xy / lightNormal.z *
        vec2(shadowProjection[2][2] / shadowProjection[0][0],
             shadowProjection[2][2] / shadowProjection[1][1]);
    float visibility = 0.0;
    for (int y = -1; y <= 1; ++y) {
        for (int x = -1; x <= 1; ++x) {
            vec2 sampleUV = (floor(uvDepth.xy / texel) + vec2(float(x), float(y)) + 0.5) * texel;
            float storedDepth = texture2D(shadowtex0, sampleUV).r;
            float receiverDepth = uvDepth.z + dot(depthGradient, sampleUV - uvDepth.xy);
            visibility += step(receiverDepth - 0.00003, storedDepth);
        }
    }
    float edgeFade = smoothstep(shadowDistance * 0.75, shadowDistance, length(scenePosition.xz));
    return mix(visibility / 9.0, 1.0, edgeFade);
}

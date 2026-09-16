uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform vec3 sunPosition;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;
uniform vec3 skyColor;
uniform float frameTimeCounter;

// okay so this should make the rainStrength get shared with fog.glsl when both are turned on

#if BLOHO_FOG == 0 || !defined BLOHO_FOGGED
uniform float rainStrength;
#endif
#if BLOHO_SHADOWS == 1 && BLOHO_DIMENSION == 0 && !defined BLOHO_HAND
#include "/lib/shadow.glsl"
#endif

vec3 blohoLighting(vec3 surfaceColor, vec3 lightmapColor, vec3 normal, vec2 lm,
                   vec3 scenePosition, float id) {
    float normalSize = length(normal);
    if (normalSize <= 0.0) return surfaceColor * lightmapColor;
    vec3 n = normal / normalSize;
    vec3 worldNormal = mat3(gbufferModelViewInverse) * n;
    float blockLight = smoothstep(0.05, 1.0, lm.x);
    float skyLight = smoothstep(0.05, 1.0, lm.y);
    vec3 localTint = mix(vec3(1.0), vec3(1.18, 0.9, 0.66), blockLight * TORCH_WARMTH);
    vec3 lit = surfaceColor * lightmapColor * localTint;

#if BLOHO_DIMENSION == 0
    vec3 sunWorld = mat3(gbufferModelViewInverse) * sunPosition;
    float sunHeight = sunWorld.y / max(length(sunWorld), 1.0);
    float daylight = smoothstep(-0.08, 0.15, sunHeight);
    vec3 lightDirection = shadowLightPosition / max(length(shadowLightPosition), 0.000001);
    float visibility = 1.0;
#if BLOHO_SHADOWS == 1 && !defined BLOHO_HAND
    visibility = blohoShadow(scenePosition, worldNormal);
#endif
    float facing = max(dot(n, lightDirection), 0.0);
    float dusk = daylight * (1.0 - smoothstep(0.02, 0.3, abs(sunHeight)));
    vec3 direct = mix(vec3(0.5, 0.64, 0.95), vec3(1.35, 1.2, 0.98), daylight);
    direct = mix(direct, vec3(1.5, 0.94, 0.57), dusk * 0.6);
    vec3 ambient = mix(vec3(0.55, 0.64, 0.82), vec3(0.48, 0.59, 0.75), daylight);
    vec3 directional = ambient + direct * facing * visibility * (1.0 - 0.7 * rainStrength);
    float directionalWeight = skyLight * (1.0 - 0.65 * blockLight) * LIGHTING_STRENGTH;
    lit *= mix(vec3(1.0), directional, directionalWeight);

#if BLOHO_WATER == 1 && defined BLOHO_TERRAIN
    if (abs(id - 1.0) < 0.25) {
        vec3 worldPosition = scenePosition + cameraPosition;
        vec2 ripples = vec2(sin(worldPosition.x * 0.85 + worldPosition.z * 0.38 + frameTimeCounter * 1.3),
                            cos(worldPosition.z * 0.73 - worldPosition.x * 0.29 + frameTimeCounter * 0.9));
        vec3 waterNormal = normalize(worldNormal + vec3(ripples.x, 0.0, ripples.y) * 0.065);
        vec3 waterViewNormal = normalize(mat3(gbufferModelView) * waterNormal);
        vec3 viewPosition = mat3(gbufferModelView) * scenePosition;
        vec3 toEye = -viewPosition / max(length(viewPosition), 0.000001);
        float grazing = pow(1.0 - clamp(abs(dot(waterViewNormal, toEye)), 0.0, 1.0), 4.0);
        vec3 reflectedSky = mix(vec3(0.04, 0.07, 0.13), skyColor, daylight);
        lit = mix(lit, reflectedSky, (0.06 + 0.34 * grazing) * skyLight);
        float shine = pow(max(dot(reflect(-lightDirection, waterViewNormal), toEye), 0.0), 80.0);
        lit += direct * shine * visibility * skyLight * (1.0 - rainStrength) * 1.4;
    }
#endif
#else
    // The Nether and End have no Overworld sun/shadow dependency.
    float faceLight = 0.72 + 0.28 * max(worldNormal.y, 0.0);
    lit *= mix(1.0, faceLight, LIGHTING_STRENGTH);
#endif

#ifdef BLOHO_TERRAIN
    if (abs(id - 2.0) < 0.25 || abs(id - 5.0) < 0.25) {
        float brightTexel = smoothstep(0.25, 0.85, max(surfaceColor.r, max(surfaceColor.g, surfaceColor.b)));
        lit = max(lit, surfaceColor * (1.0 + EMISSIVE_STRENGTH * brightTexel));
    }
#endif
    return lit;
}

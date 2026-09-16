#include "/lib/geometry_interface.glsl"
#if BLOHO_FOG == 1 && defined BLOHO_FOGGED
#include "/lib/fog.glsl"
#endif
#if BLOHO_LIGHTING == 1 && defined BLOHO_SURFACE
#include "/lib/lighting.glsl"
#endif
#if BLOHO_ORES == 1 && defined BLOHO_TERRAIN
#include "/lib/ore_emission.glsl"
#endif

#ifdef BLOHO_TEXTURED
uniform sampler2D gtexture;
#endif
#ifdef BLOHO_LIGHTMAP
uniform sampler2D lightmap;
#endif
#ifdef BLOHO_ENTITY_TINT
uniform vec4 entityColor;
#endif

void main() {
#if BLOHO_CLOUDS == 1 && BLOHO_DIMENSION == 0 && defined BLOHO_VANILLA_CLOUDS
    // Replaced by the procedural layer in deferred, only when enabled.
    discard;
#endif
    vec4 surface = vertexTint;
#ifdef BLOHO_TEXTURED
    vec4 rawTexel = texture2D(gtexture, surfaceUV);
    surface *= rawTexel;
#endif
#ifdef BLOHO_ENTITY_TINT
    surface.rgb = mix(surface.rgb, entityColor.rgb, entityColor.a);
#endif
    vec3 illumination = vec3(1.0);
#ifdef BLOHO_LIGHTMAP
    illumination = texture2D(lightmap, lightUV).rgb;
#endif
    // With legacy gl_FragData, Iris/OptiFine applies the current alpha test.
    // Do not replace the input alpha with opaque alpha or a fixed threshold.
    vec3 sceneColor = surface.rgb * illumination;
#if BLOHO_LIGHTING == 1 && defined BLOHO_SURFACE
    sceneColor = blohoLighting(surface.rgb, illumination, viewNormal, lightUV, lightingScenePosition, materialId);
#endif
#if BLOHO_ORES == 1 && defined BLOHO_TERRAIN
    sceneColor = blohoOreEmission(sceneColor, surface.rgb, rawTexel.rgb, materialId);
#endif
#if BLOHO_FOG == 1 && defined BLOHO_FOGGED
    sceneColor = blohoFog(sceneColor, fogViewPosition);
#endif
    gl_FragData[0] = vec4(sceneColor, surface.a);

#ifdef BLOHO_SURFACE
    // Metadata is never alpha blended. This is a single visible surface,
    // not a representation of multiple translucent layers.
    gl_FragData[1] = surface;
    float normalLength = length(viewNormal);
    vec3 unitNormal = vec3(0.0);
    float normalValid = 0.0;
    if (normalLength > 0.0) {
        unitNormal = viewNormal / normalLength;
        normalValid = 1.0;
    }
    gl_FragData[2] = vec4(unitNormal * 0.5 + 0.5, normalValid);
    gl_FragData[3] = vec4(lightUV, materialId, BLOHO_FAMILY);
#endif
}




#ifndef BLOHO_GEOMETRY_INTERFACE
#define BLOHO_GEOMETRY_INTERFACE
#include "/settings.glsl"
varying vec4 vertexTint;
#if BLOHO_LIGHTING == 1 && defined BLOHO_SURFACE
varying vec3 lightingScenePosition;
#endif
#if BLOHO_FOG == 1 && defined BLOHO_FOGGED
varying vec3 fogViewPosition;
#endif
#ifdef BLOHO_TEXTURED
varying vec2 surfaceUV;
#endif
#ifdef BLOHO_LIGHTMAP
varying vec2 lightUV;
#endif
#ifdef BLOHO_SURFACE
varying vec3 viewNormal;
varying float materialId;
#endif
#endif

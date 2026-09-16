#include "/lib/geometry_interface.glsl"
#if BLOHO_LIGHTING == 1 && defined BLOHO_SURFACE
uniform mat4 gbufferModelViewInverse;
#endif

#ifdef BLOHO_TERRAIN
attribute vec3 mc_Entity;
#endif
#ifdef BLOHO_ENTITY
uniform int entityId;
#endif
#ifdef BLOHO_BLOCK_ENTITY
uniform int blockEntityId;
#endif

void main() {
    // same engine transform for geo and overlays
    gl_Position = ftransform();
    vertexTint = gl_Color;
#if BLOHO_LIGHTING == 1 && defined BLOHO_SURFACE
    lightingScenePosition = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz;
#endif
#if BLOHO_FOG == 1 && defined BLOHO_FOGGED
    fogViewPosition = (gl_ModelViewMatrix * gl_Vertex).xyz;
#endif
#ifdef BLOHO_TEXTURED
    surfaceUV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
#endif
#ifdef BLOHO_LIGHTMAP
    lightUV = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
#endif
#ifdef BLOHO_SURFACE
    viewNormal = gl_NormalMatrix * gl_Normal;
    materialId = -1.0;
#ifdef BLOHO_TERRAIN
    materialId = mc_Entity.x;
#endif
#ifdef BLOHO_ENTITY
    materialId = float(entityId);
#endif
#ifdef BLOHO_BLOCK_ENTITY
    materialId = float(blockEntityId);
#endif
#endif
}





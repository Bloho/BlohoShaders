#include "/settings.glsl"
#include "/lib/shadow_config.glsl"
varying vec2 shadowUV;
varying vec4 shadowTint;
varying float shadowMaterial;
attribute vec3 mc_Entity;

void main() {
    // light-camera matrices
    gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * gl_Vertex);
    shadowUV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    shadowTint = gl_Color;
    shadowMaterial = mc_Entity.x;
}


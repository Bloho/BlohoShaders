#version 120

#include "/lib/common.glsl"
#include "/lib/settings.glsl"
#include "/lib/lighting.glsl"

uniform sampler2D gtexture;

varying vec2 texcoord;
varying vec4 vertexColor;
varying vec3 normal;

void main() {
    vec4 texColor = texture2D(texture, texcoord);

    if (texColor.a < 0.1) {
        discard;
    }

    vec3 N = normalize(normal);

    float topLight = N.y * 0.5 + 0.5;
    topLight = clamp(topLight, 0.0, 1.0);

    vec3 ambient = vec3(0.65, 0.72, 0.82);
    vec3 directional = vec3(1.00, 0.94, 0.82);

    vec3 lighting = ambient + directional * topLight * 0.35;

    vec3 finalColor = texColor.rgb * vertexColor.rgb * lighting;

    gl_FragData[0] = vec4(finalColor, texColor.a * vertexColor.a);
}
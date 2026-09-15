#version 120

uniform sampler2D gtexture;

varying vec2 texcoord;
varying vec4 vertexColor;

void main() {
    vec4 texColor = texture2D(texture, texcoord);

    gl_FragData[0] = texColor * vertexColor;
}
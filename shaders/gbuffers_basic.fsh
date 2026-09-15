#version 120

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 vertexColor;

void main() {
    vec4 texcolor = texture2D(texture, tecoord);

    gl_FragData[0] = texColor * vertexColor;
}
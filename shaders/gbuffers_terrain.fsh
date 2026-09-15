#version 120

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 vertexColor;

void main() {
    vec4 texColor = texture2D(texture, texcoord);

    if (texColor.a < 0.1) {
        discard;
    }

    gl_FragData[0] = texColor * vertexColor;
}
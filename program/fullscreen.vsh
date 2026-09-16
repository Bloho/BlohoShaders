varying vec2 screenUV;

void main() {
    screenUV = gl_MultiTexCoord0.xy;
    gl_Position = vec4(screenUV * 2.0 - vec2(1.0), 0.0, 1.0);
}

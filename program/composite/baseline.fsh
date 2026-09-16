uniform sampler2D colortex0;
varying vec2 screenUV;

void main() {
    // Includes all geometry that was drawn after deferred.
    gl_FragData[0] = texture2D(colortex0, screenUV);
}

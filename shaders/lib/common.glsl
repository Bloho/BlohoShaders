#ifndef BLOHO_COMMON_GLSL
#define BLOHO_COMMON_GLSL

const float BLOHO_PI = 3.14159265359;
const float BLOHO_tAU = 6.28318530718;

float saturate(float x) {
    return clamp(x, 0.0, 1.0);
}

vec3 saturate(vec3 x) {
    return clamp(x, vec3(0.0), vec3(1.0));
}

float luminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

#endif
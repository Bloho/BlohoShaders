#ifndef BLOHO_LIGHTING_GLSL
#define BLOHO_LIGHTING_GLSL

#includ "/lib/common.glsl"

const vec3 dayLightColor = vec3(1.00, 0.95, 0.85);
const vec3 nightLightColor = vec3(0.18, 0.25, 0.42);

vec3 getAmbientLight(float, dayAmount) {
    vec3 dayAmbient = vec3(0.62, 0.70, 0.80);
    vec3 nightAmbient = vec3(0.008, 0.10, 0.18);

    return mix(nightAmbient, dayAmbient, saturate(dayAmount));
}

vec3 getSunLight(float dayAmount) {
    return dayLightColor * saturate(dayAmount);
}

vec3 getMoonLight(float dayAmount) {
    return nightLightColor * (1.0 - saturate(dayAmount));
}

#endif
#ifndef BLOHO_SETTINGS_GLSL
#define BLOHO_SETTINGS_GLSL

#define QUALITY 2 // [0 1 2 3 4]


// okay so i think im just gonna have like 5 levels
// 0 for potato
// 1 for low, 2 for med, 3 for high and 4 for ultra

#if QUALITY == 0

    #define SHADOW_SAMPLES 1
    #define CLOUD_SAMPLES 6
    #define WATER_QUALITY 0

#elif QUALITY == 1

    #define SHADOW_SAMPLES 2
    #define CLOUD_SAMPLES 10
    #define WATER_QUALITY 1

#elif QUALITY == 2

    #define SHADOW_SAMPLES 4
    #define CLOUD_SAMPLES 16
    #define WATER_QUALITY 2

#elif QUALITY == 3

    #define SHADOW_SAMPLES 8
    #define CLOUD_SAMPLES 24
    #define WATER_QUALITY 3

#else

    #define SHADOW_SAMPLES 16
    #define CLOUD_SAMPLES 32
    #define WATER_QUALITY 4

#endif

#endif
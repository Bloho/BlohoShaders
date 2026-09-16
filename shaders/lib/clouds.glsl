uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform vec3 sunPosition;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform float rainStrength;
uniform float frameTimeCounter;
uniform int isEyeInWater;

float blohoCloudHash(vec2 cell) {
    return fract(sin(dot(cell, vec2(43.0, 137.0))) * 15937.0);
}

float blohoCloudNoise(vec2 point) {
    vec2 cell = floor(point);
    vec2 local = fract(point);
    vec2 blend = local * local * (3.0 - 2.0 * local);
    return mix(mix(blohoCloudHash(cell), blohoCloudHash(cell + vec2(1.0, 0.0)), blend.x),
               mix(blohoCloudHash(cell + vec2(0.0, 1.0)), blohoCloudHash(cell + vec2(1.0)), blend.x), blend.y);
}

float blohoCloudField(vec2 point) {
    float broad = blohoCloudNoise(point);
    float medium = blohoCloudNoise(point * 2.0 + vec2(19.0, 7.0));
    float small = blohoCloudNoise(point * 4.0 + vec2(3.0, 29.0));
    return (broad * 4.0 + medium * 2.0 + small) / 7.0;
}

vec3 blohoCloudLayer(vec3 background, vec3 worldRay, float hitDistance,
                     float sceneDistance, float layer) {
    if (hitDistance <= 0.0 || hitDistance >= sceneDistance || hitDistance > 1800.0) {
        return background;
    }
    vec2 drift = frameTimeCounter * CLOUD_SPEED * vec2(0.7, 0.23);
    vec2 cloudPoint = (cameraPosition.xz + worldRay.xz * hitDistance + drift) / 220.0;
    cloudPoint += layer * vec2(13.0, 31.0);
    float field = blohoCloudField(cloudPoint);
    float coverage = clamp(CLOUD_COVERAGE + rainStrength * 0.12, 0.0, 1.0);
    float density = smoothstep(1.0 - coverage, 1.16 - coverage, field);
    float horizonFade = smoothstep(0.02, 0.12, abs(worldRay.y));
    float distanceFade = 1.0 - smoothstep(1000.0, 1800.0, hitDistance);
    // Fades gently 
    float nearFade = smoothstep(0.0, 10.0, hitDistance);
    float opacity = density * 0.78 * horizonFade * distanceFade * nearFade;

    vec3 worldSun = mat3(gbufferModelViewInverse) * sunPosition;
    float sunHeight = worldSun.y / max(length(worldSun), 1.0);
    float day = smoothstep(-0.08, 0.18, sunHeight);
    float dusk = (1.0 - smoothstep(0.0, 0.25, abs(sunHeight))) * day;
    vec3 litCloud = mix(vec3(0.96, 0.98, 1.0), vec3(1.0, 0.79, 0.64), dusk * 0.55);
    vec3 cloudColor = mix(vec3(0.12, 0.17, 0.25), litCloud, day);
    cloudColor *= 1.0 - 0.2 * density - 0.22 * rainStrength;
    cloudColor = mix(cloudColor, max(skyColor, vec3(0.0)), 0.12);
    cloudColor = mix(cloudColor, fogColor, smoothstep(300.0, 1800.0, hitDistance) * 0.65);
    return mix(background, cloudColor, opacity);
}

vec3 blohoClouds(vec3 background, vec2 uv) {
    if (isEyeInWater != 0) return background;
    float depth = texture2D(depthtex0, uv).r;
    vec4 viewH = gbufferProjectionInverse * vec4(uv * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    if (abs(viewH.w) < 0.000001) return background;
    vec3 viewPosition = viewH.xyz / viewH.w;
    float sceneDistance = length(viewPosition);
    if (sceneDistance <= 0.0) return background;
    vec3 worldRay = mat3(gbufferModelViewInverse) * (viewPosition / sceneDistance);
    if (abs(worldRay.y) < 0.02) return background;
    // Sky depth is far-plane depth,
    if (depth >= 1.0) sceneDistance = 1800.0;
    float lowerDistance = (CLOUD_HEIGHT - cameraPosition.y) / worldRay.y;
    float upperDistance = (CLOUD_HEIGHT + 28.0 - cameraPosition.y) / worldRay.y;
    // Composite far sheet first
    if (upperDistance > lowerDistance) {
        background = blohoCloudLayer(background, worldRay, upperDistance, sceneDistance, 1.0);
        background = blohoCloudLayer(background, worldRay, lowerDistance, sceneDistance, 0.0);
    } else {
        background = blohoCloudLayer(background, worldRay, lowerDistance, sceneDistance, 0.0);
        background = blohoCloudLayer(background, worldRay, upperDistance, sceneDistance, 1.0);
    }
    return background;
}

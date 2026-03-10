#include <flutter/runtime_effect.glsl>

uniform vec2 u_resolution;
uniform float u_time;

out vec4 fragColor;

float random(vec2 st, float time) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233)) + time) * 43758.5453123);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    float grainSize = 3.0;
    vec2 blockCoord = floor(fragCoord / grainSize);
    float noise = random(blockCoord, u_time * 10.0);
    noise = pow(noise, 3.0);
    float intensity = 0.15;
    vec3 grainColor = vec3(1.0, 1.0, 1.0);
    float alpha = noise * intensity;
    fragColor = vec4(grainColor * alpha, alpha);
}

#version 150

// Lunar Vacuum Space Fog Override
// Completely eliminates atmospheric fog (End purple #A080A0 and Overworld blue)
// so the Moon's vacuum, craters, stars, and caverns render with crisp clarity.

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
    // Zero atmospheric fog in the vacuum of space
    return inColor;
}

float linear_fog_fade(float vertexDistance, float fogStart, float fogEnd) {
    return 1.0;
}

float cylindrical_distance(vec3 pos) {
    return length(pos.xz);
}

float spherical_distance(vec3 pos) {
    return length(pos);
}

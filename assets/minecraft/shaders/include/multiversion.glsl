#moj_import <fog.glsl>

uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;

vec4 applyFog(vec4 inColor, float modifier) {
    return linear_fog(inColor, vertexDistance * modifier, FogStart, FogEnd, FogColor);
}

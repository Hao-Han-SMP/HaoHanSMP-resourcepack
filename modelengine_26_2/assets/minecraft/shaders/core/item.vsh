#version 330

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:sample_lightmap.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
// MCC start - add extra outputs
flat out int hideVertex;
out vec4 lightMapColor;
out vec4 normalLightValue;
// MCC end - add extra outputs

// MCC start - add function to get if GUI
bool isGUI(mat4 ProjMat) {
    return ProjMat[2][3] == 0.0;
}
// MCC end - add function to get if GUI

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);

    vertexColor = Color; // MCC - perform lighting in fragment shader

    texCoord0 = UV0;
    // MCC start - add nearby culling and emissive
    if (gl_Position.w <= 1.4 && !isGUI(ProjMat)) {
        hideVertex = 1;
    } else {
        hideVertex = 0;
    }

    normalLightValue = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1.0));
    lightMapColor = sample_lightmap(Sampler2, UV2);
    // MCC end - add nearby culling and emissive
}

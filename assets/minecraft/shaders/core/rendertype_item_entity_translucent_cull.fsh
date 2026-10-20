#version 150

uniform sampler2D Sampler0;

in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 baseColor;

#moj_import <minecraft:multiversion.glsl>

in vec3 vertexPosition;

out vec4 fragColor;

#moj_import <minecraft:utils.glsl>
#moj_import <minecraft:model_effects.glsl>

#moj_import <minecraft:skyboxes/lunar_lib.glsl>

// Value noise & hash inspired by Cosmic Horizons (black_hole.fsh)
float chHash(float x) { return fract(sin(x) * 152754.742); }
float chHash2(vec2 x) { return chHash(x.x + chHash(x.y)); }
float chValueNoise(vec2 p, float f) {
    vec2 pFloor = floor(p * f);
    vec2 fr = fract(p * f);
    fr = (3.0 - 2.0 * fr) * fr * fr;
    float bl = chHash2(pFloor);
    float br = chHash2(pFloor + vec2(1.0, 0.0));
    float tl = chHash2(pFloor + vec2(0.0, 1.0));
    float tr = chHash2(pFloor + vec2(1.0, 1.0));
    return mix(mix(bl, br, fr.x), mix(tl, tr, fr.x), fr.y);
}

// Singularity Accretion Disk Shader with Relativistic Cosmic Horizons Physics
vec4 hhBlackHole(float r, float ang, float t) {
    float horizon = 0.20;
    if (r < horizon) {
        discard;
    }

    float t_sec = t * 0.05;
    // Spiral swirl accelerates near event horizon
    float swirl = ang + 2.8 / (r + 0.06) - t_sec * 2.2;

    // Cosmic Horizons Value-Noise Turbulent Plasma Streams (f=45 & f=90)
    vec2 polarCoords = vec2(swirl / 6.2831853, r * 3.5 - t_sec * 0.4);
    float nPlasma = chValueNoise(polarCoords, 45.0) * 0.66 + chValueNoise(polarCoords, 90.0) * 0.34;
    float spiralArms = 0.5 + 0.5 * sin(swirl * 2.0 + r * 12.0);

    // Accretion disk profile: peaks at photon sphere (0.22 - 0.28), smooth falloff to 0.98
    float diskFactor = smoothstep(horizon, 0.26, r) * (1.0 - smoothstep(0.68, 0.98, r));
    float photonRing = exp(-pow((r - 0.22) / 0.012, 2.0)) * 5.5;
    float innerGlow  = exp(-pow((r - 0.25) / 0.035, 2.0)) * 3.2;

    // Relativistic Doppler Beaming & Gravitational Redshift (Cosmic Horizons model)
    // Left side moving towards observer is blue-shifted & intensely boosted; right side is red-shifted
    float parallel = sin(ang - 0.35); // velocity projection along line of sight
    float beamBoost = pow(clamp(0.5 + 0.5 * parallel, 0.15, 1.0), 1.8) * 2.2;
    float redShift = clamp(0.5 - 0.5 * parallel, 0.0, 1.0);

    // Color palette: Relativistic shift between Cyan/White hot (approaching) and Deep Violet/Amber (receding)
    vec3 colBlueShifted = mix(vec3(0.20, 0.85, 1.00), vec3(1.00, 1.00, 1.00), 0.7);
    vec3 colRedShifted  = mix(vec3(0.45, 0.08, 0.90), vec3(0.95, 0.35, 0.12), redShift * 0.6);
    vec3 accretionColor = mix(colBlueShifted, colRedShifted, redShift);

    // Composite plasma brightness with Cosmic Horizons noise modulation
    float plasmaDensity = (0.55 + 0.45 * nPlasma) * (0.7 + 0.3 * spiralArms);
    vec3 diskRgb = accretionColor * diskFactor * plasmaDensity * beamBoost * 2.2;
    vec3 ringRgb = vec3(0.95, 0.98, 1.0) * photonRing + vec3(0.35, 0.85, 1.0) * innerGlow;
    vec3 finalRgb = diskRgb + ringRgb;

    // Outer edge smooth antialiasing to prevent jagged pixel cutoff
    float edgeFade = 1.0 - smoothstep(0.90, 0.98, r);
    float alpha = clamp((diskFactor * 1.4 + innerGlow * 0.85 + photonRing) * edgeFade, 0.0, 1.0);

    return vec4(finalRgb, alpha);
}

void main() {
    fragColor = vec4(0.0);
    vec2 screenPosNormalized = gl_FragCoord.xy / ScreenSize;
    vec3 worldDirection = normalize(vertexPosition);

    #moj_import <minecraft:skybox_config.glsl>
    if (fragColor.a > 0.0) return;

    vec4 tex = texture(Sampler0, texCoord0);
    if (tex.a < 0.05) discard;

    float rawA = tex.a * 255.0;
    int marker = int(round(rawA));
    float t = GameTime * 1200.0;
    vec4 color;
    if (abs(rawA - 231.0) < 1.2) {
        color = hhBlackHole(tex.r, tex.g * 6.2831853, t) * ColorModulator;
        if (color.a < 0.02) discard;
    } else if (abs(rawA - 232.0) < 1.2) {
        // High-precision circular distance from disk center
        vec2 centeredUv = texCoord0 * 2.0 - 1.0;
        float distFromCenter = length(centeredUv);
        if (distFromCenter > 1.0) discard;

        float pulse = 0.85 + 0.35 * sin(t * 6.0);
        float edgeSoft = 1.0 - smoothstep(0.92, 1.0, distFromCenter);
        vec3 glowCol = tex.rgb * (pulse * 1.6);
        color = vec4(glowCol, edgeSoft) * ColorModulator;
    } else if (abs(rawA - 233.0) < 1.2) {
        color = vec4(0.0, 0.0, 0.0, 1.0);
    } else if (marker >= 170 && marker <= 220) {
        float sa = float(marker - 170) / 50.0;
        if (sa < 0.02) discard;
        color = vec4(tex.rgb, sa) * ColorModulator;
    } else {
        color = tex * vertexColor * ColorModulator;
        if (color.a < 0.1) discard;
    }
    if (rawA >= 169.0 && rawA <= 235.0) {
        fragColor = color;
    } else {
        fragColor = applyFog(color, 1.0);
    }
}

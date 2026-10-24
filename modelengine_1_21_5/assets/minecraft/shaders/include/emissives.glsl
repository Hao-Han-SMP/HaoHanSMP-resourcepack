#define ALPHA(value, override) if(alpha == value) return override;

int checkEmissive(int alpha) {
    // Defines all alpha values that will render as emissive.
    return -1;
}

int checkUnlit(int alpha) {
    // Defines all alpha values that will render as unlit.
    ALPHA(252, 255)
    ALPHA(251, 255)
    ALPHA(245, 255)
    ALPHA(235, 235)
    ALPHA(231, 231)
    ALPHA(202, 202)
    ALPHA(201, 201)
    ALPHA(200, 200)
    ALPHA(182, 182)
    ALPHA(181, 181)
    ALPHA(152, 152)
    ALPHA(142, 142)
    ALPHA(141, 141)
    ALPHA(102, 102)
    ALPHA(101, 101)
    ALPHA(82, 82)
    ALPHA(52, 52)
    ALPHA(22, 22)

    return -1;
}

int checkNoNormalShading(int alpha) {
    // Defines all alpha values that will render without normal shading.
    ALPHA(253, 255)
    ALPHA(250, 255)
    ALPHA(233, 233)
    ALPHA(230, 230)
    ALPHA(203, 203)
    ALPHA(183, 183)
    ALPHA(180, 180)
    ALPHA(153, 153)
    ALPHA(143, 143)
    ALPHA(140, 140)
    ALPHA(103, 103)
    ALPHA(100, 100)
    ALPHA(53, 53)
    ALPHA(23, 23)

    return -1;
}

int checkHalfEmissive(int alpha) {
    // Defines all alpha values that will render half-emissive.
    ALPHA(247, 255)

    return -1;
}

// Determines the rounded integer alpha value of a pixel.
int getAlpha(float a) {
    return int(round(a * 255.00));
}

// Applies lighting based on various parameters.
vec4 applyLighting(int alpha, vec4 albedo, vec4 normalLighting, vec4 lightmap) {
    int unlit           = checkUnlit(alpha);
    int noNormalShading = checkNoNormalShading(alpha);
    int emissive        = checkEmissive(alpha);
    int halfEmissive    = checkHalfEmissive(alpha);

    if(unlit != -1) {
        albedo.a = unlit / 255.0;
        return albedo;
    }

    if(noNormalShading != -1) {
        albedo.a = noNormalShading / 255.0;;
        return albedo * lightmap;
    }

    if(emissive != -1) {
        albedo.a = emissive / 255.0;
        return albedo * normalLighting;
    }

    if(halfEmissive != -1) {
        albedo.a = halfEmissive / 255.0;
        return albedo * mix(normalLighting * lightmap, vec4(1.0), 0.5);
    }

    return albedo * normalLighting * lightmap;
}

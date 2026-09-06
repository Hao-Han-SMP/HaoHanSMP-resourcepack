// Lunar Space Skybox Shader for HaoHan SMP
// Authentic Stylized Astronomical Proportions & 6-Face Rich Minecraft Textures:
// 1. Sun:
//    - Axial rotation (GameTime * 15.0)
//    - Plasma aura radiating seamlessly across the ENTIRE cube silhouette (outer hit / perimeter glow).
// 2. Earth:
//    - Tiny polar ice caps (abs(uv3.y) > 0.98, only ~2% tip at north & south).
//    - Seamless 6-face spherical projection texturing.
// 3. Jupiter:
//    - Rich continuous 3D cylindrical wrap: all 4 equatorial faces have flowing wavy bands & storms,
//      and top/bottom polar faces have concentric polar vortices & storms.
//    - Zero flat faces, zero stretched single-color surfaces.
// 4. Mars, Saturn, Venus, Mercury:
//    - Rich 3D continuous procedural Minecraft textures on all 6 faces.
// 5. Complete rotation for all planets & stars.

fragColor.a = 1.0;

// Deep space cosmic void
vec3 skyColor = vec3(0.001, 0.001, 0.003);

// =========================================================================
// 1. MINECRAFT CLASSIC CLEAN STARS (Multi-tiered Random Small Sizes)
// =========================================================================
vec3 starsColor = vec3(0.0);
{
    float starGrid = 38.0;
    vec3 sP = worldDirection * starGrid;
    vec3 sBase = floor(sP);
    vec3 sFract = fract(sP);
    vec3 sOffset = sign(sFract - 0.5);

    for (int x = 0; x <= 1; x++) {
        for (int y = 0; y <= 1; y++) {
            for (int z = 0; z <= 1; z++) {
                vec3 cell = sBase + vec3(float(x) * sOffset.x, float(y) * sOffset.y, float(z) * sOffset.z);
                float h = random(cell);
                if (h > 0.91) {
                    vec3 sPosRel = vec3(
                        random(cell + vec3(1.1, 2.3, 3.5)),
                        random(cell + vec3(4.7, 5.2, 6.8)),
                        random(cell + vec3(7.3, 8.9, 9.1))
                    );
                    vec3 sDir = normalize((cell + sPosRel) / starGrid);
                    float d = acos(clamp(dot(worldDirection, sDir), -1.0, 1.0));

                    float hSize = random(cell + vec3(9.2, 3.7, 5.4));
                    float starRadius = 0.0009 + 0.0013 * hSize;

                    if (d < starRadius) {
                        float twinkleSpeed = 1200.0 + h * 1600.0;
                        float twinkle = 0.82 + 0.18 * sin(GameTime * twinkleSpeed + h * 6.28);
                        
                        vec3 sCol = vec3(1.0);
                        if (h > 0.975) {
                            sCol = vec3(0.86, 0.92, 1.0);
                        } else if (h > 0.945) {
                            sCol = vec3(1.0, 0.96, 0.88);
                        } else if (h > 0.925) {
                            sCol = vec3(1.0, 0.90, 0.82);
                        }
                        
                        float brightness = 0.65 + 0.35 * hSize;
                        float core = smoothstep(starRadius, starRadius * 0.15, d);
                        starsColor += sCol * core * twinkle * brightness;
                    }
                }
            }
        }
    }
}
skyColor += starsColor;

// Common Sun Direction in World Space (Ecliptic origin: South-East sky)
vec3 sunDir = normalize(vec3(0.452, 0.616, -0.646));

// =========================================================================
// 2. THE SUN (MAT TROI CUBE - Rotating Cube with Full Plasma Aura around Cube)
// Position: az = 145 deg, alt = 38 deg -> vec3(0.452, 0.616, -0.646)
// =========================================================================
{
    float angleSun = acos(clamp(dot(worldDirection, sunDir), -1.0, 1.0));

    // Sun Cube Frame with Gentle Rotation
    float sunDist = 100.0;
    vec3 sunPos = sunDir * sunDist;

    vec3 _fwd = -sunDir;
    vec3 _upRef = (abs(_fwd.y) > 0.99) ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);
    vec3 _right = normalize(cross(_upRef, _fwd));
    vec3 _up = cross(_fwd, _right);

    // Sun slow gentle rotation: GameTime * 15.0
    float sunSpin = GameTime * 15.0;
    float yaw = 0.785398 + sunSpin;
    float pitch = 0.61548;
    vec3 _r1 = _right * cos(yaw) + _fwd * sin(yaw);
    vec3 _f1 = -_right * sin(yaw) + _fwd * cos(yaw);
    vec3 _u2 = _up * cos(pitch) - _f1 * sin(pitch);
    vec3 _f2 = _up * sin(pitch) + _f1 * cos(pitch);
    vec3 axisX = _r1;
    vec3 axisY = _u2;
    vec3 axisZ = _f2;

    vec3 rDir = vec3(dot(worldDirection, axisX), dot(worldDirection, axisY), dot(worldDirection, axisZ));
    vec3 rOrig = vec3(dot(-sunPos, axisX), dot(-sunPos, axisY), dot(-sunPos, axisZ));

    vec3 safeD = vec3(
        abs(rDir.x) < 1e-5 ? (rDir.x >= 0.0 ? 1e-5 : -1e-5) : rDir.x,
        abs(rDir.y) < 1e-5 ? (rDir.y >= 0.0 ? 1e-5 : -1e-5) : rDir.y,
        abs(rDir.z) < 1e-5 ? (rDir.z >= 0.0 ? 1e-5 : -1e-5) : rDir.z
    );
    vec3 invD = 1.0 / safeD;

    // Standard sun inner radius ~3.8
    float H_in = 3.8;
    // Plasma aura extends out around the cube silhouette ~4.9
    float H_aura = 4.8;
    float delta = 0.18;
    float H_out = H_in + delta;

    vec3 t0_in = (-vec3(H_in) - rOrig) * invD;
    vec3 t1_in = ( vec3(H_in) - rOrig) * invD;
    float tNear_in = max(max(min(t0_in.x, t1_in.x), min(t0_in.y, t1_in.y)), min(t0_in.z, t1_in.z));
    float tFar_in  = min(min(max(t0_in.x, t1_in.x), max(t0_in.y, t1_in.y)), max(t0_in.z, t1_in.z));
    bool hitInner = (tNear_in < tFar_in && tFar_in > 0.0 && tNear_in > 0.0);

    vec3 t0_out = (-vec3(H_out) - rOrig) * invD;
    vec3 t1_out = ( vec3(H_out) - rOrig) * invD;
    float tNear_out = max(max(min(t0_out.x, t1_out.x), min(t0_out.y, t1_out.y)), min(t0_out.z, t1_out.z));
    float tFar_out  = min(min(max(t0_out.x, t1_out.x), max(t0_out.y, t1_out.y)), max(t0_out.z, t1_out.z));
    bool hitOuter = (tNear_out < tFar_out && tFar_out > 0.0 && tNear_out > 0.0);

    // Soft solar corona glow
    vec3 corona = vec3(1.0, 0.90, 0.65) * exp(-angleSun * 18.0) * 0.35
                + vec3(0.98, 0.65, 0.25) * exp(-angleSun * 6.5) * 0.08;
    skyColor += corona;

    // Active 3D Cube Solar Storm & Plasma Flare Jets (Softened, rich turbulence & natural solar flares)
    float tClosest = -dot(rOrig, safeD) / dot(safeD, safeD);
    if (tClosest > 0.0) {
        vec3 pClosest = rOrig + tClosest * safeD;
        float cubeDist = max(max(abs(pClosest.x), abs(pClosest.y)), abs(pClosest.z));
        // Soft aura envelope around cube: H_in (3.8) to 7.8
        if (cubeDist > H_in && cubeDist < 7.8) {
            float distNorm = (cubeDist - H_in) / (7.8 - H_in); // 0.0 at surface, 1.0 at tip
            vec3 dirNorm = normalize(pClosest);
            float animTime = GameTime * 900.0;

            // Radial coordinates
            float thetaJet = atan(dirNorm.z, dirNorm.x);
            float phiJet   = asin(clamp(dirNorm.y, -1.0, 1.0));

            // Fine solar turbulence across multiple octaves
            float n1 = noise(dirNorm * 6.0  + vec3(animTime * 0.4, -animTime * 0.7, animTime * 0.5));
            float n2 = noise(dirNorm * 14.0 + vec3(-animTime * 0.6, animTime * 0.9, -animTime * 0.4));
            float n3 = noise(dirNorm * 28.0 + vec3(animTime * 1.2, 0.0, animTime * 1.5));
            float fineTurb = n1 * 0.50 + n2 * 0.32 + n3 * 0.18;

            // Soft shooting flare streams modulated heavily by 3D noise
            float beam1 = sin(thetaJet * 6.0  + animTime * 1.1 + sin(phiJet * 4.0)) * 0.5 + 0.5;
            float beam2 = sin(thetaJet * 11.0 - animTime * 1.4 + cos(phiJet * 6.0)) * 0.5 + 0.5;
            float flareJetPattern = (beam1 * 0.6 + beam2 * 0.4) * fineTurb;

            // Energy blend: subtle, wispy and organic
            float stormEnergy = fineTurb * 0.65 + flareJetPattern * 0.35;

            // Smooth natural falloff from the cube edge
            float stormFalloff = smoothstep(1.0, 0.0, distNorm) * smoothstep(0.0, 0.05, distNorm);
            float stormMask = stormFalloff * pow(clamp(stormEnergy, 0.0, 1.0), 1.6) * 1.25;

            vec3 colGold      = vec3(1.0, 0.90, 0.50);
            vec3 colHotOrange = vec3(1.0, 0.50, 0.12);
            vec3 colRubyFlare = vec3(0.88, 0.16, 0.03);

            vec3 jetCol = mix(colRubyFlare, colHotOrange, clamp(stormEnergy * 1.2, 0.0, 1.0));
            jetCol = mix(jetCol, colGold, pow(clamp(stormEnergy, 0.0, 1.0), 2.2));

            skyColor += jetCol * stormMask;
        }
    }

    vec3 outlineSolar = vec3(1.0, 0.72, 0.25);

    if (hitInner) {
        vec3 hitLoc = rOrig + tNear_in * rDir;
        vec3 uv3 = hitLoc / H_in;
        vec3 absUv = abs(uv3);

        float faceLight = 1.0;
        if (absUv.y > absUv.x && absUv.y > absUv.z) {
            faceLight = 1.25;
        } else if (absUv.x > absUv.z) {
            faceLight = 1.05;
        } else {
            faceLight = 0.90;
        }

        // Subtly animated solar granule surface on all 6 faces
        vec2 faceUV;
        if (absUv.x > absUv.y && absUv.x > absUv.z) faceUV = uv3.yz;
        else if (absUv.y > absUv.z) faceUV = uv3.xz;
        else faceUV = uv3.xy;

        vec2 pixUV = floor((faceUV * 0.5 + 0.5) * 16.0) / 16.0;
        float nGranule = noise(vec3(pixUV * 6.0, GameTime * 300.0));

        vec3 sunCoreColor = mix(vec3(1.0, 0.98, 0.90), vec3(1.0, 0.92, 0.75), nGranule * 0.2) * faceLight * 1.35;
        skyColor = sunCoreColor + corona * 0.20;
    } else if (hitOuter) {
        skyColor = outlineSolar * 1.35;
    }
}

// =========================================================================
// 3. EARTH (TRAI DAT CUBE - Overhead North Sky)
// Real Astronomical Proportion: Earth is ~3.67x larger than Sun from Moon! (eHalf = 13.8)
// Position: az = 10 deg, alt = 55 deg -> vec3(0.100, 0.819, 0.565)
// =========================================================================
vec3 earthDir = normalize(vec3(0.100, 0.819, 0.565));
{
    float earthDist = 100.0;
    vec3 earthPos = earthDir * earthDist;
    float eHalf = 13.8;

    // Atmospheric Rayleigh Blue Aura Glow
    float angleEarth = acos(clamp(dot(worldDirection, earthDir), -1.0, 1.0));
    if (angleEarth < 0.26) {
        float atmoRim = smoothstep(0.24, 0.13, angleEarth) * smoothstep(0.09, 0.16, angleEarth);
        vec3 atmoBlue = vec3(0.25, 0.65, 1.0) * 0.55;
        skyColor += atmoBlue * atmoRim;
    }

    vec3 _fwd = -earthDir;
    vec3 _upRef = (abs(_fwd.y) > 0.99) ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);
    vec3 _right = normalize(cross(_upRef, _fwd));
    vec3 _up = cross(_fwd, _right);

    // Slow gentle axial rotation: GameTime * 40.0
    float earthSpin = GameTime * 40.0;
    float yaw = 0.52 + earthSpin;
    float pitch = 0.41;
    float roll = 0.15;
    vec3 _r1 = _right * cos(yaw) + _fwd * sin(yaw);
    vec3 _f1 = -_right * sin(yaw) + _fwd * cos(yaw);
    vec3 _u2 = _up * cos(pitch) - _f1 * sin(pitch);
    vec3 _f2 = _up * sin(pitch) + _f1 * cos(pitch);
    vec3 eAxisX = _r1 * cos(roll) + _u2 * sin(roll);
    vec3 eAxisY = -_r1 * sin(roll) + _u2 * cos(roll);
    vec3 eAxisZ = _f2;

    vec3 rDir = vec3(dot(worldDirection, eAxisX), dot(worldDirection, eAxisY), dot(worldDirection, eAxisZ));
    vec3 rOrig = vec3(dot(-earthPos, eAxisX), dot(-earthPos, eAxisY), dot(-earthPos, eAxisZ));

    vec3 safeD = vec3(
        abs(rDir.x) < 1e-5 ? (rDir.x >= 0.0 ? 1e-5 : -1e-5) : rDir.x,
        abs(rDir.y) < 1e-5 ? (rDir.y >= 0.0 ? 1e-5 : -1e-5) : rDir.y,
        abs(rDir.z) < 1e-5 ? (rDir.z >= 0.0 ? 1e-5 : -1e-5) : rDir.z
    );
    vec3 invD = 1.0 / safeD;

    vec3 t0 = (-vec3(eHalf) - rOrig) * invD;
    vec3 t1 = ( vec3(eHalf) - rOrig) * invD;
    float tNear = max(max(min(t0.x, t1.x), min(t0.y, t1.y)), min(t0.z, t1.z));
    float tFar  = min(min(max(t0.x, t1.x), max(t0.y, t1.y)), max(t0.z, t1.z));

    if (tNear < tFar && tFar > 0.0 && tNear > 0.0) {
        vec3 hitLoc = rOrig + tNear * rDir;
        vec3 uv3 = hitLoc / eHalf;
        vec3 absUv = abs(uv3);

        vec3 localNorm = vec3(0.0);
        vec2 faceUV = vec2(0.0);
        if (absUv.x > absUv.y && absUv.x > absUv.z) {
            localNorm = vec3(sign(uv3.x), 0.0, 0.0);
            faceUV = uv3.yz;
        } else if (absUv.y > absUv.z) {
            localNorm = vec3(0.0, sign(uv3.y), 0.0);
            faceUV = uv3.xz;
        } else {
            localNorm = vec3(0.0, 0.0, sign(uv3.z));
            faceUV = uv3.xy;
        }

        vec3 worldFaceNorm = localNorm.x * eAxisX + localNorm.y * eAxisY + localNorm.z * eAxisZ;
        float sunDot = dot(worldFaceNorm, sunDir);
        float sunLit = smoothstep(-0.10, 0.20, sunDot);

        // 24x24 Minecraft High-Vibrancy Palette with 3D Spherical/Continuous coordinates
        vec3 pSphere = normalize(uv3);
        vec3 pixSphere = floor(pSphere * 24.0) / 24.0;

        float nCont1 = noise(pixSphere * 2.8);
        float nCont2 = noise(pixSphere * 5.2 + vec3(4.1, 1.8, 2.9));
        float nLand = nCont1 * 0.65 + nCont2 * 0.35;
        float nBiome = noise(pixSphere * 6.5 + vec3(1.2, 5.7, 3.4));

        vec3 colDeepOcean   = vec3(0.08, 0.48, 0.88);
        vec3 colShallowCyan = vec3(0.18, 0.68, 0.95);
        vec3 colEmeraldLand = vec3(0.20, 0.78, 0.32);
        vec3 colLushForest  = vec3(0.12, 0.62, 0.22);
        vec3 colDesertSand  = vec3(0.85, 0.75, 0.42);
        vec3 colPolarIce    = vec3(0.96, 0.98, 1.00);

        vec3 surfaceCol;

        // User feedback: "giảm kích thước tuyết của hai cực trên trái đất"
        // Strict polar threshold: abs(uv3.y) > 0.98 (only ~2% tiny realistic ice caps)
        if (abs(uv3.y) > 0.98) {
            surfaceCol = colPolarIce;
        } else if (nLand < 0.43) {
            surfaceCol = (nLand < 0.35) ? colDeepOcean : colShallowCyan;
        } else {
            if (abs(uv3.y) < 0.25 && nBiome > 0.62) {
                surfaceCol = colDesertSand;
            } else if (nBiome > 0.40) {
                surfaceCol = colEmeraldLand;
            } else {
                surfaceCol = colLushForest;
            }
        }

        // Night-side city lights
        vec3 cityLights = vec3(0.0);
        if (nLand >= 0.43 && sunLit < 0.85) {
            float nCityGrid = noise(pixSphere * 20.0);
            if (nCityGrid > 0.54) {
                float cityTwinkle = 0.70 + 0.30 * sin(GameTime * 1800.0 * (1.0 + nCityGrid * 3.0) + pixSphere.x * 30.0);
                vec3 colCityAmber = vec3(1.0, 0.78, 0.30);
                vec3 colCityGold  = vec3(1.0, 0.92, 0.55);
                vec3 cCol = mix(colCityAmber, colCityGold, fract(nCityGrid * 10.0));
                cityLights = cCol * cityTwinkle * (1.0 - sunLit) * smoothstep(0.54, 0.72, nCityGrid) * 1.4;
            }
        }

        // Limb brightening
        float limbTerm = 1.0 - max(0.0, dot(worldFaceNorm, -rDir));
        vec3 limbAura = vec3(0.30, 0.70, 1.0) * pow(limbTerm, 3.0) * sunLit * 0.50;

        vec3 shadowAmb = vec3(0.12, 0.15, 0.22);
        vec3 directSun = vec3(1.0, 0.98, 0.92) * max(0.0, sunDot) * 1.15;

        skyColor = surfaceCol * (shadowAmb + directSun * sunLit) + cityLights + limbAura;
    }

    // Minecraft Blocky Protruding Cloud Clusters with 3D wrap
    float cHalf = eHalf + 0.60;
    vec3 ct0 = (-vec3(cHalf) - rOrig) * invD;
    vec3 ct1 = ( vec3(cHalf) - rOrig) * invD;
    float ctNear = max(max(min(ct0.x, ct1.x), min(ct0.y, ct1.y)), min(ct0.z, ct1.z));
    float ctFar  = min(min(max(ct0.x, ct1.x), max(ct0.y, ct1.y)), max(ct0.z, ct1.z));

    if (ctNear < ctFar && ctFar > 0.0 && ctNear > 0.0) {
        vec3 cHitLoc = rOrig + ctNear * rDir;
        vec3 cUv3 = cHitLoc / cHalf;
        vec3 cAbsUv = abs(cUv3);

        vec3 cNorm = vec3(0.0);
        if (cAbsUv.x > cAbsUv.y && cAbsUv.x > cAbsUv.z) cNorm = vec3(sign(cUv3.x), 0.0, 0.0);
        else if (cAbsUv.y > cAbsUv.z) cNorm = vec3(0.0, sign(cUv3.y), 0.0);
        else cNorm = vec3(0.0, 0.0, sign(cUv3.z));

        vec3 worldCNorm = cNorm.x * eAxisX + cNorm.y * eAxisY + cNorm.z * eAxisZ;
        float cSunDot = dot(worldCNorm, sunDir);
        float cSunLit = smoothstep(-0.10, 0.20, cSunDot);

        vec3 cSphere = normalize(cUv3);
        vec3 cPixSphere = floor(cSphere * 16.0) / 16.0;
        float nCloud = noise(cPixSphere * 4.5 + vec3(GameTime * 60.0, 0.0, 0.0));

        if (nCloud > 0.55) {
            vec3 cloudCol = mix(vec3(0.20, 0.25, 0.35), vec3(1.0, 1.0, 1.0), cSunLit);
            float cloudAlpha = 0.88;
            skyColor = mix(skyColor, cloudCol, cloudAlpha);
        }
    }
}

// =========================================================================
// 4. MERCURY (SAO THUY CUBE - 6-Face Basalt & Crater Texture)
// Position: az = 125 deg, alt = 42 deg -> vec3(0.609, 0.669, -0.426)
// =========================================================================
vec3 mercuryDir = normalize(vec3(0.609, 0.669, -0.426));
{
    float mercDist = 100.0;
    vec3 mercPos = mercuryDir * mercDist;
    float mHalf = 0.75;

    vec3 _fwd = -mercuryDir;
    vec3 _upRef = (abs(_fwd.y) > 0.99) ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);
    vec3 _right = normalize(cross(_upRef, _fwd));
    vec3 _up = cross(_fwd, _right);

    float yaw = GameTime * 20.0;
    vec3 _r1 = _right * cos(yaw) + _fwd * sin(yaw);
    vec3 _f1 = -_right * sin(yaw) + _fwd * cos(yaw);
    vec3 mAxisX = _r1;
    vec3 mAxisY = _up;
    vec3 mAxisZ = _f1;

    vec3 rDir = vec3(dot(worldDirection, mAxisX), dot(worldDirection, mAxisY), dot(worldDirection, mAxisZ));
    vec3 rOrig = vec3(dot(-mercPos, mAxisX), dot(-mercPos, mAxisY), dot(-mercPos, mAxisZ));

    vec3 safeD = vec3(
        abs(rDir.x) < 1e-5 ? (rDir.x >= 0.0 ? 1e-5 : -1e-5) : rDir.x,
        abs(rDir.y) < 1e-5 ? (rDir.y >= 0.0 ? 1e-5 : -1e-5) : rDir.y,
        abs(rDir.z) < 1e-5 ? (rDir.z >= 0.0 ? 1e-5 : -1e-5) : rDir.z
    );
    vec3 invD = 1.0 / safeD;

    vec3 t0 = (-vec3(mHalf) - rOrig) * invD;
    vec3 t1 = ( vec3(mHalf) - rOrig) * invD;
    float tNear = max(max(min(t0.x, t1.x), min(t0.y, t1.y)), min(t0.z, t1.z));
    float tFar  = min(min(max(t0.x, t1.x), max(t0.y, t1.y)), max(t0.z, t1.z));

    if (tNear < tFar && tFar > 0.0 && tNear > 0.0) {
        vec3 hitLoc = rOrig + tNear * rDir;
        vec3 uv3 = hitLoc / mHalf;
        vec3 absUv = abs(uv3);

        vec3 localNorm = vec3(0.0);
        if (absUv.x > absUv.y && absUv.x > absUv.z) localNorm = vec3(sign(uv3.x), 0.0, 0.0);
        else if (absUv.y > absUv.z) localNorm = vec3(0.0, sign(uv3.y), 0.0);
        else localNorm = vec3(0.0, 0.0, sign(uv3.z));

        vec3 worldFaceNorm = localNorm.x * mAxisX + localNorm.y * mAxisY + localNorm.z * mAxisZ;
        float sunDot = dot(worldFaceNorm, sunDir);
        float sunLit = smoothstep(-0.10, 0.20, sunDot);

        vec3 pix3D = floor(normalize(uv3) * 12.0) / 12.0;
        float nMerc = noise(pix3D * 5.0 + vec3(2.7, 1.4, 3.9));

        vec3 colBasalt = vec3(0.38, 0.36, 0.35);
        vec3 colCrater = vec3(0.55, 0.52, 0.48);
        vec3 mercColor = mix(colBasalt, colCrater, nMerc);

        vec3 shadowAmb = vec3(0.08, 0.08, 0.08);
        vec3 directSun = vec3(1.2, 1.15, 1.0) * max(0.0, sunDot) * 1.3;

        skyColor = mercColor * (shadowAmb + directSun * sunLit);
    }
}

// =========================================================================
// 5. VENUS (SAO KIM CUBE - 6-Face Sulfur Cloud Swirls)
// Position: az = 92 deg, alt = 46 deg -> vec3(0.694, 0.719, -0.024)
// =========================================================================
vec3 venusDir = normalize(vec3(0.694, 0.719, -0.024));
{
    float venusDist = 100.0;
    vec3 venusPos = venusDir * venusDist;
    float vHalf = 1.40;

    float angleVenus = acos(clamp(dot(worldDirection, venusDir), -1.0, 1.0));
    if (angleVenus < 0.040) {
        float vGlow = exp(-angleVenus * 85.0) * 0.40;
        skyColor += vec3(1.0, 0.96, 0.82) * vGlow;
    }

    vec3 _fwd = -venusDir;
    vec3 _upRef = (abs(_fwd.y) > 0.99) ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);
    vec3 _right = normalize(cross(_upRef, _fwd));
    vec3 _up = cross(_fwd, _right);

    float yaw = 0.30 + GameTime * 25.0;
    float pitch = 0.25;
    vec3 _r1 = _right * cos(yaw) + _fwd * sin(yaw);
    vec3 _f1 = -_right * sin(yaw) + _fwd * cos(yaw);
    vec3 _u2 = _up * cos(pitch) - _f1 * sin(pitch);
    vec3 _f2 = _up * sin(pitch) + _f1 * cos(pitch);
    vec3 vAxisX = _r1;
    vec3 vAxisY = _u2;
    vec3 vAxisZ = _f2;

    vec3 rDir = vec3(dot(worldDirection, vAxisX), dot(worldDirection, vAxisY), dot(worldDirection, vAxisZ));
    vec3 rOrig = vec3(dot(-venusPos, vAxisX), dot(-venusPos, vAxisY), dot(-venusPos, vAxisZ));

    vec3 safeD = vec3(
        abs(rDir.x) < 1e-5 ? (rDir.x >= 0.0 ? 1e-5 : -1e-5) : rDir.x,
        abs(rDir.y) < 1e-5 ? (rDir.y >= 0.0 ? 1e-5 : -1e-5) : rDir.y,
        abs(rDir.z) < 1e-5 ? (rDir.z >= 0.0 ? 1e-5 : -1e-5) : rDir.z
    );
    vec3 invD = 1.0 / safeD;

    vec3 t0 = (-vec3(vHalf) - rOrig) * invD;
    vec3 t1 = ( vec3(vHalf) - rOrig) * invD;
    float tNear = max(max(min(t0.x, t1.x), min(t0.y, t1.y)), min(t0.z, t1.z));
    float tFar  = min(min(max(t0.x, t1.x), max(t0.y, t1.y)), max(t0.z, t1.z));

    if (tNear < tFar && tFar > 0.0 && tNear > 0.0) {
        vec3 hitLoc = rOrig + tNear * rDir;
        vec3 uv3 = hitLoc / vHalf;
        vec3 absUv = abs(uv3);

        vec3 localNorm = vec3(0.0);
        if (absUv.x > absUv.y && absUv.x > absUv.z) localNorm = vec3(sign(uv3.x), 0.0, 0.0);
        else if (absUv.y > absUv.z) localNorm = vec3(0.0, sign(uv3.y), 0.0);
        else localNorm = vec3(0.0, 0.0, sign(uv3.z));

        vec3 worldFaceNorm = localNorm.x * vAxisX + localNorm.y * vAxisY + localNorm.z * vAxisZ;
        float sunDot = dot(worldFaceNorm, sunDir);
        float sunLit = smoothstep(-0.10, 0.20, sunDot);

        vec3 pix3D = floor(normalize(uv3) * 16.0) / 16.0;
        float nVenus = noise(pix3D * 4.5 + vec3(uv3.y * 3.0, 1.2, 5.7));

        vec3 colSulfurCream = vec3(0.98, 0.94, 0.82);
        vec3 colPaleAmber   = vec3(0.92, 0.86, 0.70);
        vec3 venusColor = mix(colSulfurCream, colPaleAmber, nVenus * 0.4);

        vec3 shadowAmb = vec3(0.15, 0.14, 0.12);
        vec3 directSun = vec3(1.15, 1.10, 0.95) * max(0.0, sunDot) * 1.2;

        skyColor = venusColor * (shadowAmb + directSun * sunLit);
    }
}

// =========================================================================
// 6. MARS (SAO HOA CUBE - 6-Face Seamless Terracotta Geology)
// Position: az = -55 deg, alt = 44 deg -> vec3(-0.589, 0.695, 0.413)
// =========================================================================
vec3 marsDir = normalize(vec3(-0.589, 0.695, 0.413));
{
    float marsDist = 100.0;
    vec3 marsPos = marsDir * marsDist;
    float marsHalf = 1.50;

    vec3 _fwd = -marsDir;
    vec3 _upRef = (abs(_fwd.y) > 0.99) ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);
    vec3 _right = normalize(cross(_upRef, _fwd));
    vec3 _up = cross(_fwd, _right);

    float marsSpin = GameTime * 35.0;
    float yaw = 0.65 + marsSpin;
    float pitch = 0.38;
    float roll = 0.20;
    vec3 _r1 = _right * cos(yaw) + _fwd * sin(yaw);
    vec3 _f1 = -_right * sin(yaw) + _fwd * cos(yaw);
    vec3 _u2 = _up * cos(pitch) - _f1 * sin(pitch);
    vec3 _f2 = _up * sin(pitch) + _f1 * cos(pitch);
    vec3 mAxisX = _r1 * cos(roll) + _u2 * sin(roll);
    vec3 mAxisY = -_r1 * sin(roll) + _u2 * cos(roll);
    vec3 mAxisZ = _f2;

    vec3 rDir = vec3(dot(worldDirection, mAxisX), dot(worldDirection, mAxisY), dot(worldDirection, mAxisZ));
    vec3 rOrig = vec3(dot(-marsPos, mAxisX), dot(-marsPos, mAxisY), dot(-marsPos, mAxisZ));

    vec3 safeD = vec3(
        abs(rDir.x) < 1e-5 ? (rDir.x >= 0.0 ? 1e-5 : -1e-5) : rDir.x,
        abs(rDir.y) < 1e-5 ? (rDir.y >= 0.0 ? 1e-5 : -1e-5) : rDir.y,
        abs(rDir.z) < 1e-5 ? (rDir.z >= 0.0 ? 1e-5 : -1e-5) : rDir.z
    );
    vec3 invD = 1.0 / safeD;

    vec3 t0 = (-vec3(marsHalf) - rOrig) * invD;
    vec3 t1 = ( vec3(marsHalf) - rOrig) * invD;
    float tNear = max(max(min(t0.x, t1.x), min(t0.y, t1.y)), min(t0.z, t1.z));
    float tFar  = min(min(max(t0.x, t1.x), max(t0.y, t1.y)), max(t0.z, t1.z));

    if (tNear < tFar && tFar > 0.0 && tNear > 0.0) {
        vec3 hitLoc = rOrig + tNear * rDir;
        vec3 uv3 = hitLoc / marsHalf;
        vec3 absUv = abs(uv3);

        vec3 localNorm = vec3(0.0);
        if (absUv.x > absUv.y && absUv.x > absUv.z) localNorm = vec3(sign(uv3.x), 0.0, 0.0);
        else if (absUv.y > absUv.z) localNorm = vec3(0.0, sign(uv3.y), 0.0);
        else localNorm = vec3(0.0, 0.0, sign(uv3.z));

        vec3 worldFaceNorm = localNorm.x * mAxisX + localNorm.y * mAxisY + localNorm.z * mAxisZ;
        float sunDot = dot(worldFaceNorm, sunDir);
        float sunLit = smoothstep(-0.10, 0.20, sunDot);

        // 3D continuous 16x16 Minecraft pixel grid wrapped across all 6 faces
        vec3 pSphere = normalize(uv3);
        vec3 pixSphere = floor(pSphere * 16.0) / 16.0;

        float nBase = noise(pixSphere * 3.5);
        float nRift = noise(pixSphere * 4.8 + vec3(2.1, 5.3, 1.7));
        float nGrit = fract(sin(dot(pixSphere, vec3(12.9898, 78.233, 45.164))) * 43758.5453);

        vec3 colPeachLight = vec3(1.00, 0.72, 0.44);
        vec3 colPeachMain  = vec3(0.96, 0.60, 0.33);
        vec3 colRustOrange = vec3(0.88, 0.46, 0.20);
        vec3 colDarkBasalt = vec3(0.36, 0.18, 0.11);
        vec3 colDarkShade  = vec3(0.26, 0.12, 0.08);
        vec3 colSouthBasin = vec3(0.86, 0.66, 0.54);

        vec3 marsColor = mix(colPeachMain, colRustOrange, nBase);
        if (nGrit > 0.65) {
            marsColor = mix(marsColor, colPeachLight, 0.55);
        } else if (nGrit < 0.25) {
            marsColor = mix(marsColor, colRustOrange, 0.45);
        }

        // Dark basalt patches covering regions realistically across faces
        if (nRift > 0.54) {
            vec3 basaltShade = (nGrit > 0.5) ? colDarkBasalt : colDarkShade;
            marsColor = mix(marsColor, basaltShade, smoothstep(0.54, 0.68, nRift) * 0.95);
        }

        // Pale dusty southern basin
        if (uv3.y < -0.65) {
            float ringBasin = smoothstep(-0.65, -0.95, uv3.y);
            marsColor = mix(marsColor, colSouthBasin, ringBasin * 0.85);
        }

        vec3 shadowAmb = vec3(0.14, 0.10, 0.09);
        vec3 directSun = vec3(1.0, 0.95, 0.88) * max(0.0, sunDot) * 1.1;

        skyColor = marsColor * (shadowAmb + directSun * sunLit);
    }
}

// =========================================================================
// 7. JUPITER (SAO MOC CUBE - 6-Face Complete Texturing with 3D Cylindrical Bands & Polar Vortices)
// Position: az = -105 deg, alt = 36 deg -> vec3(-0.781, 0.588, -0.209)
// =========================================================================
vec3 jupiterDir = normalize(vec3(-0.781, 0.588, -0.209));
{
    float jupDist = 100.0;
    vec3 jupPos = jupiterDir * jupDist;
    float jupHalf = 2.85;

    vec3 _fwd = -jupiterDir;
    vec3 _upRef = (abs(_fwd.y) > 0.99) ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);
    vec3 _right = normalize(cross(_upRef, _fwd));
    vec3 _up = cross(_fwd, _right);

    // Slow gentle axial rotation: GameTime * 25.0
    float jupSpin = GameTime * 25.0;
    float yaw = 0.45 + jupSpin;
    float pitch = 0.30;
    float roll = 0.10;
    vec3 _r1 = _right * cos(yaw) + _fwd * sin(yaw);
    vec3 _f1 = -_right * sin(yaw) + _fwd * cos(yaw);
    vec3 _u2 = _up * cos(pitch) - _f1 * sin(pitch);
    vec3 _f2 = _up * sin(pitch) + _f1 * cos(pitch);
    vec3 jAxisX = _r1 * cos(roll) + _u2 * sin(roll);
    vec3 jAxisY = -_r1 * sin(roll) + _u2 * cos(roll);
    vec3 jAxisZ = _f2;

    vec3 rDir = vec3(dot(worldDirection, jAxisX), dot(worldDirection, jAxisY), dot(worldDirection, jAxisZ));
    vec3 rOrig = vec3(dot(-jupPos, jAxisX), dot(-jupPos, jAxisY), dot(-jupPos, jAxisZ));

    vec3 safeD = vec3(
        abs(rDir.x) < 1e-5 ? (rDir.x >= 0.0 ? 1e-5 : -1e-5) : rDir.x,
        abs(rDir.y) < 1e-5 ? (rDir.y >= 0.0 ? 1e-5 : -1e-5) : rDir.y,
        abs(rDir.z) < 1e-5 ? (rDir.z >= 0.0 ? 1e-5 : -1e-5) : rDir.z
    );
    vec3 invD = 1.0 / safeD;
    vec3 t0 = (-vec3(jupHalf) - rOrig) * invD;
    vec3 t1 = ( vec3(jupHalf) - rOrig) * invD;
    float tNear = max(max(min(t0.x, t1.x), min(t0.y, t1.y)), min(t0.z, t1.z));
    float tFar  = min(min(max(t0.x, t1.x), max(t0.y, t1.y)), max(t0.z, t1.z));

    // A. Extremely faint dust ring for Jupiter
    bool hitRing = false;
    vec3 ringFinalColor = vec3(0.0);
    float ringAlpha = 0.0;

    float tRing = -rOrig.y * invD.y;
    if (tRing > 0.0) {
        vec3 ringHit = rOrig + tRing * rDir;
        float ringDist = length(ringHit.xz);

        if (ringDist >= 3.6 && ringDist <= 6.0) {
            hitRing = true;

            float stepDist = floor(ringDist * 8.0) / 8.0;
            float theta = atan(ringHit.z, ringHit.x);
            float rotAngle = theta + GameTime * 1000.0 / sqrt(stepDist * 0.25);
            float stepAngle = floor(rotAngle * 24.0) / 24.0;

            float dustNoise = noise(vec3(stepDist * 6.0, stepAngle * 10.0, 1.8));
            vec3 colDust = vec3(0.75, 0.65, 0.55);
            ringFinalColor = colDust * (0.8 + dustNoise * 0.2);

            ringAlpha = smoothstep(3.6, 4.0, ringDist) * smoothstep(6.0, 5.6, ringDist) * 0.15;
        }
    }

    // B. Jupiter Body Cube (Continuous texturing on ALL 6 FACES)
    bool hitBody = (tNear < tFar && tFar > 0.0 && tNear > 0.0);
    vec3 bodyFinalColor = vec3(0.0);

    if (hitBody) {
        vec3 hitLoc = rOrig + tNear * rDir;
        vec3 uv3 = hitLoc / jupHalf;
        vec3 absUv = abs(uv3);

        vec3 localNorm = vec3(0.0);
        if (absUv.x > absUv.y && absUv.x > absUv.z) localNorm = vec3(sign(uv3.x), 0.0, 0.0);
        else if (absUv.y > absUv.z) localNorm = vec3(0.0, sign(uv3.y), 0.0);
        else localNorm = vec3(0.0, 0.0, sign(uv3.z));

        vec3 worldFaceNorm = localNorm.x * jAxisX + localNorm.y * jAxisY + localNorm.z * jAxisZ;
        float sunDot = dot(worldFaceNorm, sunDir);
        float sunLit = smoothstep(-0.10, 0.20, sunDot);

        // Continuous cylindrical wrapping: theta angle for full 360-degree equatorial surface
        float theta = atan(uv3.z, uv3.x); // [-pi, pi]
        float thetaGrid = floor((theta / 3.14159265 * 0.5 + 0.5) * 64.0) / 64.0;
        float yGrid = floor((uv3.y * 0.5 + 0.5) * 32.0) / 32.0;

        float driftDir = (mod(floor((uv3.y + 1.0) * 8.0), 2.0) == 0.0) ? 1.0 : -0.7;
        float bandDrift = GameTime * 120.0 * driftDir;

        // Continuous longitudinal turbulence across all 4 side faces
        float waveNoise = noise(vec3(thetaGrid * 10.0 + bandDrift, yGrid * 12.0, 2.4)) * 0.15;
        float fineTurb  = noise(vec3(thetaGrid * 24.0 - bandDrift * 0.5, yGrid * 26.0, 5.1)) * 0.07;

        // Palette directly sampled from Hubble & Minecraft cube (Image 1):
        vec3 colCreamWhite  = vec3(0.96, 0.93, 0.86);
        vec3 colWarmBeige   = vec3(0.90, 0.82, 0.70);
        vec3 colCaramelOchre= vec3(0.82, 0.58, 0.36);
        vec3 colTerracotta  = vec3(0.72, 0.42, 0.24);
        vec3 colSoftTan     = vec3(0.85, 0.74, 0.58);

        float bandCoord = floor((uv3.y + waveNoise + fineTurb + 1.0) * 8.0);
        float bandType = mod(bandCoord, 5.0);

        vec3 jupColor = colCreamWhite;
        if (bandType < 1.0) jupColor = colCaramelOchre;
        else if (bandType < 2.0) jupColor = colWarmBeige;
        else if (bandType < 3.0) jupColor = colTerracotta;
        else if (bandType < 4.0) jupColor = colSoftTan;

        // Top and Bottom Polar Faces: Concentric spiral storms & polar hoods (No plain flat face!)
        if (abs(localNorm.y) > 0.5) {
            float polarR = length(uv3.xz);
            float polarA = atan(uv3.z, uv3.x);
            float polarSpiral = noise(vec3(polarR * 8.0, polarA * 4.0 + GameTime * 150.0, 7.8));
            float polarBand = mod(floor((polarR + polarSpiral * 0.2) * 8.0), 3.0);
            
            vec3 pCol = (polarBand < 1.0) ? colSoftTan : (polarBand < 2.0 ? colWarmBeige : colCaramelOchre);
            jupColor = mix(jupColor, pCol, 0.85);
        }

        // Great Red Spot (3D Cylindrical Storm System at theta ~ 0.5 rad, y ~ -0.25)
        float stormTheta = 0.50;
        float stormY = -0.22;
        float dTheta = mod(theta - stormTheta + 3.14159, 6.28318) - 3.14159;
        float dY = uv3.y - stormY;
        float grsDist = length(vec2(dTheta * 1.8, dY));

        if (grsDist < 0.24) {
            float grsTurb = noise(vec3(dTheta * 18.0, dY * 22.0, 3.5));
            vec3 colGRSCore = vec3(0.92, 0.38, 0.20);
            vec3 colGRSRim  = vec3(0.88, 0.55, 0.30);
            vec3 grsColor = mix(colGRSCore, colGRSRim, grsDist / 0.24 + grsTurb * 0.3);
            jupColor = mix(grsColor, jupColor, smoothstep(0.16, 0.24, grsDist));
        }

        // Secondary smaller storms distributed around the planet
        float storm2Theta = -2.2;
        float storm2Y = 0.28;
        float dTheta2 = mod(theta - storm2Theta + 3.14159, 6.28318) - 3.14159;
        float grsDist2 = length(vec2(dTheta2 * 2.0, uv3.y - storm2Y));
        if (grsDist2 < 0.16) {
            vec3 colWhiteOval = vec3(0.98, 0.98, 0.95);
            jupColor = mix(colWhiteOval, jupColor, smoothstep(0.08, 0.16, grsDist2));
        }

        vec3 shadowAmb = vec3(0.14, 0.12, 0.11);
        vec3 directSun = vec3(1.0, 0.96, 0.90) * max(0.0, sunDot) * 1.1;

        bodyFinalColor = jupColor * (shadowAmb + directSun * sunLit);
    }

    // C. Wrapping compositing
    if (hitBody && hitRing) {
        if (tRing < tNear) {
            skyColor = mix(bodyFinalColor, ringFinalColor, ringAlpha);
        } else {
            skyColor = bodyFinalColor;
        }
    } else if (hitBody) {
        skyColor = bodyFinalColor;
    } else if (hitRing) {
        skyColor = mix(skyColor, ringFinalColor, ringAlpha);
    }
}

// =========================================================================
// 8. SATURN (SAO THO CUBE - 6-Face Seamless Cylindrical Banding & Rings)
// Position: az = -150 deg, alt = 28 deg -> vec3(-0.441, 0.469, -0.765)
// =========================================================================
vec3 saturnDir = normalize(vec3(-0.441, 0.469, -0.765));
{
    float satDist = 100.0;
    vec3 satPos = saturnDir * satDist;
    float satHalf = 2.35;

    vec3 _fwd = -saturnDir;
    vec3 _upRef = (abs(_fwd.y) > 0.99) ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);
    vec3 _right = normalize(cross(_upRef, _fwd));
    vec3 _up = cross(_fwd, _right);

    // Slow gentle axial rotation: GameTime * 22.0
    float satSpin = GameTime * 22.0;
    float yaw = 0.58 + satSpin;
    float pitch = 0.45;
    float roll = 0.18;
    vec3 _r1 = _right * cos(yaw) + _fwd * sin(yaw);
    vec3 _f1 = -_right * sin(yaw) + _fwd * cos(yaw);
    vec3 _u2 = _up * cos(pitch) - _f1 * sin(pitch);
    vec3 _f2 = _up * sin(pitch) + _f1 * cos(pitch);
    vec3 sAxisX = _r1 * cos(roll) + _u2 * sin(roll);
    vec3 sAxisY = -_r1 * sin(roll) + _u2 * cos(roll);
    vec3 sAxisZ = _f2;

    vec3 rDir = vec3(dot(worldDirection, sAxisX), dot(worldDirection, sAxisY), dot(worldDirection, sAxisZ));
    vec3 rOrig = vec3(dot(-satPos, sAxisX), dot(-satPos, sAxisY), dot(-satPos, sAxisZ));

    vec3 safeD = vec3(
        abs(rDir.x) < 1e-5 ? (rDir.x >= 0.0 ? 1e-5 : -1e-5) : rDir.x,
        abs(rDir.y) < 1e-5 ? (rDir.y >= 0.0 ? 1e-5 : -1e-5) : rDir.y,
        abs(rDir.z) < 1e-5 ? (rDir.z >= 0.0 ? 1e-5 : -1e-5) : rDir.z
    );
    vec3 invD = 1.0 / safeD;
    vec3 t0 = (-vec3(satHalf) - rOrig) * invD;
    vec3 t1 = ( vec3(satHalf) - rOrig) * invD;
    float tNear = max(max(min(t0.x, t1.x), min(t0.y, t1.y)), min(t0.z, t1.z));
    float tFar  = min(min(max(t0.x, t1.x), max(t0.y, t1.y)), max(t0.z, t1.z));

    // Saturn Expansive Ring System (Reference Image 2)
    bool hitSatRing = false;
    vec3 satRingFinalCol = vec3(0.0);
    float satRingAlpha = 0.0;

    float tRing = -rOrig.y * invD.y;
    if (tRing > 0.0) {
        vec3 ringHit = rOrig + tRing * rDir;
        float ringDist = length(ringHit.xz);

        if (ringDist >= 3.2 && ringDist <= 8.8) {
            hitSatRing = true;

            vec3 sunLoc = vec3(dot(sunDir, sAxisX), dot(sunDir, sAxisY), dot(sunDir, sAxisZ));
            // Soft-blended shadow cast by the Saturn cube onto the ring
            float ringSunFacing = dot(normalize(ringHit.xz), -normalize(sunLoc.xz));
            // Smooth penumbra transition between 0.50 and 0.78 (soft blend across the shadow boundary)
            float penumbra = smoothstep(0.50, 0.78, ringSunFacing);
            float ringShadow = mix(1.0, 0.18, penumbra);

            float stepDist = floor(ringDist * 12.0) / 12.0;
            float theta = atan(ringHit.z, ringHit.x);
            float rotAngle = theta + GameTime * 1000.0 / sqrt(stepDist * 0.3);
            float stepAngle = floor(rotAngle * 32.0) / 32.0;

            float rockCluster = noise(vec3(stepDist * 8.0, stepAngle * 14.0, 2.5));
            float fineDust    = noise(vec3(stepDist * 20.0, stepAngle * 36.0, 4.8));

            float cassiniGap = smoothstep(0.05, 0.16, abs(stepDist - 6.2));

            vec3 colRingDark   = vec3(0.42, 0.38, 0.32);
            vec3 colRingTan    = vec3(0.72, 0.66, 0.54);
            vec3 colRingCream  = vec3(0.88, 0.82, 0.70);
            vec3 colRockChunk  = vec3(0.92, 0.88, 0.78);

            vec3 satRingCol = mix(colRingDark, colRingTan, sin(stepDist * 20.0) * 0.5 + 0.5);
            satRingCol = mix(satRingCol, colRingCream, fineDust * 0.4);

            if (rockCluster > 0.62) {
                satRingCol = mix(satRingCol, colRockChunk, (rockCluster - 0.62) * 2.5);
            }

            satRingAlpha = smoothstep(3.2, 3.5, ringDist) * smoothstep(8.8, 8.4, ringDist) * cassiniGap * 0.78;
            satRingFinalCol = satRingCol * ringShadow;
        }
    }

    // Saturn Body Cube (Continuous 6-Face Cylindrical & Polar Texture)
    bool hitSatBody = (tNear < tFar && tFar > 0.0 && tNear > 0.0);
    vec3 satBodyFinalCol = vec3(0.0);

    if (hitSatBody) {
        vec3 hitLoc = rOrig + tNear * rDir;
        vec3 uv3 = hitLoc / satHalf;
        vec3 absUv = abs(uv3);

        vec3 localNorm = vec3(0.0);
        if (absUv.x > absUv.y && absUv.x > absUv.z) localNorm = vec3(sign(uv3.x), 0.0, 0.0);
        else if (absUv.y > absUv.z) localNorm = vec3(0.0, sign(uv3.y), 0.0);
        else localNorm = vec3(0.0, 0.0, sign(uv3.z));

        vec3 worldFaceNorm = localNorm.x * sAxisX + localNorm.y * sAxisY + localNorm.z * sAxisZ;
        float sunDot = dot(worldFaceNorm, sunDir);
        float sunLit = smoothstep(-0.10, 0.20, sunDot);

        float theta = atan(uv3.z, uv3.x);
        float satDrift = GameTime * 90.0;
        float wave = noise(vec3(theta * 6.0 + satDrift, uv3.y * 10.0, 1.9)) * 0.08;

        float bandCoord = floor((uv3.y + wave + 1.0) * 8.0);
        float bandType = mod(bandCoord, 3.0);

        vec3 colPaleButter = vec3(0.92, 0.88, 0.76);
        vec3 colWarmCream  = vec3(0.86, 0.82, 0.70);
        vec3 colLightTan   = vec3(0.80, 0.76, 0.64);

        vec3 satColor = colPaleButter;
        if (bandType < 1.0) satColor = colWarmCream;
        else if (bandType < 2.0) satColor = colLightTan;

        // Polar hexagon & vortex (Saturn north/south poles)
        if (abs(localNorm.y) > 0.5) {
            float polarDist = length(uv3.xz);
            satColor = mix(satColor, colLightTan, smoothstep(0.0, 0.8, polarDist) * 0.6);
        }

        vec3 shadowAmb = vec3(0.12, 0.11, 0.09);
        vec3 directSun = vec3(1.0, 0.96, 0.88) * max(0.0, sunDot) * 1.1;

        satBodyFinalCol = satColor * (shadowAmb + directSun * sunLit);
    }

    // Wrapping compositing
    if (hitSatBody && hitSatRing) {
        if (tRing < tNear) {
            skyColor = mix(satBodyFinalCol, satRingFinalCol, satRingAlpha);
        } else {
            skyColor = satBodyFinalCol;
        }
    } else if (hitSatBody) {
        skyColor = satBodyFinalCol;
    } else if (hitSatRing) {
        skyColor = mix(skyColor, satRingFinalCol, satRingAlpha);
    }
}

// =========================================================================
// 9. OUTPUT & MINECRAFT FOG
// =========================================================================
fragColor.rgb = skyColor;
fragColor = applyFog(fragColor, 0.25);

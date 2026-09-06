// Original Shader from Shadertoy
// Ported to Core Shaders by Dragoncraft
// Made some slight adjustments to the colors and calculations too


// afl_ext 2017-2024
// MIT License

// Use your mouse to move the camera around! Press the Left Mouse Button on the image to look around!

float DRAG_MULT = 0.38; // changes how much waves pull on the water
float WATER_DEPTH = 1.0; // how deep is the water
float CAMERA_HEIGHT = 1; // how high the camera should be
int ITERATIONS_RAYMARCH = 12; // waves iterations of raymarching
int ITERATIONS_normalOcean = 36; // waves iterations when calculating normalOceans


// Calculates wave value and its derivative, 
// for the wave direction, position in space, wave frequency and time
vec2 wavedxOcean(vec2 position, vec2 direction, float frequency, float timeshift) {
  float x = dot(direction, position) * frequency + timeshift;
  float wave = exp(sin(x) - 1.0);
  float dx = wave * cos(x);
  return vec2(wave, -dx);
}

// Calculates waves by summing octaves of various waves with various parameters
float getwavesOcean(vec2 position, int iterations) {
  float wavePhaseShift = length(position) * 0.1; // this is to avoid every octave having exactly the same phase everywhere
  float iter = 0.0; // this will help generating well distributed wave directions
  float frequency = 1.0; // frequency of the wave, this will change every iteration
  float timeMultiplier = 2.0; // time multiplier for the wave, this will change every iteration
  float weight = 1.0;// weight in final sum for the wave, this will change every iteration
  float sumOfValues = 0.0; // will store final sum of values
  float sumOfWeights = 0.0; // will store final sum of weights
  for(int i=0; i < iterations; i++) {
    // generate some wave direction that looks kind of random
    vec2 p = vec2(sin(iter), cos(iter));
    
    // calculate wave data
    vec2 res = wavedxOcean(position, p, frequency, GameTime * 1000 * timeMultiplier + wavePhaseShift);

    // shift position around according to wave drag and derivative of the wave
    position += p * res.y * weight * DRAG_MULT;

    // add the results to sums
    sumOfValues += res.x * weight;
    sumOfWeights += weight;

    // modify next octave ;
    weight = mix(weight, 0.0, 0.2);
    frequency *= 1.18;
    timeMultiplier *= 1.07;

    // add some kind of random value to make next wave look random too
    iter += 1232.399963;
  }
  // calculate and return
  return sumOfValues / sumOfWeights;
}

// Raymarches the ray from top water layer boundary to low water layer boundary
float raymarchwaterOcean(vec3 camera, vec3 start, vec3 end, float depth) {
  vec3 pos = start;
  vec3 dir = normalize(end - start);
  for(int i=0; i < 64; i++) {
    // the height is from 0 to -depth
    float height = getwavesOcean(pos.xz, ITERATIONS_RAYMARCH) * depth - depth;
    // if the waves height almost nearly matches the ray height, assume its a hit and return the hit distance
    if(height + 0.01 > pos.y) {
      return distance(pos, camera);
    }
    // iterate forwards according to the height mismatch
    pos += dir * (pos.y - height);
  }
  // if hit was not registered, just assume hit the top layer, 
  // this makes the raymarching faster and looks better at higher distances
  return distance(start, camera);
}

// Calculate normalOcean at point by calculating the height at the pos and 2 additional points very close to pos
vec3 normalOcean(vec2 pos, float e, float depth) {
  vec2 ex = vec2(e, 0);
  float H = getwavesOcean(pos.xy, ITERATIONS_normalOcean) * depth;
  vec3 a = vec3(pos.x, H, pos.y);
  return normalize(
    cross(
      a - vec3(pos.x - e, getwavesOcean(pos.xy - ex.xy, ITERATIONS_normalOcean) * depth, pos.y), 
      a - vec3(pos.x, getwavesOcean(pos.xy + ex.yx, ITERATIONS_normalOcean) * depth, pos.y + e)
    )
  );
}

// Helper function generating a rotation matrix around the axis by the angle
mat3 createRotationMatrixAxisAngleOcean(vec3 axis, float angle) {
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;
  return mat3(
    oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 
    oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 
    oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c
  );
}


// Ray-Plane intersection checker
float intersectPlaneOcean(vec3 origin, vec3 direction, vec3 point, vec3 normalOcean) { 
  return clamp(dot(point - origin, normalOcean) / dot(direction, normalOcean), -1.0, 9991999.0); 
}

// Some very barebones but fast atmosphere approximation
vec3 extra_cheap_atmosphereOcean(vec3 raydir, vec3 sundir) {
  sundir.y = max(sundir.y, -0.07);
  if (sundir.y < -0.07) {
    return vec3(0);
  }
  float special_trick = 1.0 / (raydir.y * 1.0 + 0.1);
  float special_trick2 = 1.0 / (sundir.y * 11.0 + 1.0);
  float raysundt = pow(abs(dot(sundir, raydir)), 2.0);
  float sundt = pow(max(0.0, dot(sundir, raydir)), 8.0);
  float mymie = sundt * special_trick * 0.2;
  vec3 suncolor = mix(vec3(1.0), max(vec3(0.0), vec3(1.0) - vec3(5.5, 13.0, 22.4) / 22.4), special_trick2);
  vec3 bluesky= vec3(5.5, 13.0, 22.4) / 22.4 * suncolor;
  vec3 bluesky2 = max(vec3(0.0), bluesky - vec3(5.5, 13.0, 22.4) * 0.002 * (special_trick + -6.0 * sundir.y * sundir.y));
  bluesky2 *= special_trick * (0.24 + raysundt * 0.24);
  return bluesky2 * (1.0 + 1.0 * pow(1.0 - raydir.y, 3.0));
} 

// Calculate where the sun should be, it will be moving around the sky
vec3 getSunOceanDirectionOcean() {
    vec3 up = vec3(0,10,0);
    up.xy *= rot2D((DayTime() - 0.25) * 2 * PI);
    return normalize(up);
}

// Get atmosphere color for given direction
vec3 getAtmosphereOcean(vec3 dir) {
   return extra_cheap_atmosphereOcean(dir, getSunOceanDirectionOcean()) * 0.5;
}

// Get sun color for given direction
float getSunOcean(vec3 dir) { 
  return pow(max(0.0, dot(dir, getSunOceanDirectionOcean())), 720.0) * 210.0;
}

// Great tonemapping function from my other shader: https://www.shadertoy.com/view/XsGfWV
vec3 aces_tonemapOcean(vec3 color) {  
  mat3 m1 = mat3(
    0.59719, 0.07600, 0.02840,
    0.35458, 0.90834, 0.13383,
    0.04823, 0.01566, 0.83777
  );
  mat3 m2 = mat3(
    1.60475, -0.10208, -0.00327,
    -0.53108,  1.10813, -0.07276,
    -0.07367, -0.00605,  1.07602
  );
  vec3 v = m1 * color;  
  vec3 a = v * (v + 0.0245786) - 0.000090537;
  vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
  return pow(clamp(m2 * (a / b), 0.0, 1.0), vec3(1.0 / 2.2));  
}

// Main
vec4 mainImageOcean(vec3 worldDirection) {
  vec4 color = vec4(0);
  // get the ray
  vec3 ray = worldDirection;

  float iTime = GameTime * 1000;
  if(ray.y >= 0.0) {
    // if ray.y is positive, render the sky
    vec3 C = getAtmosphereOcean(ray) + getSunOcean(ray);
    color = vec4(aces_tonemapOcean(C * 2.0),1.0);   
    return color;
  }

  // now ray.y must be negative, water must be hit
  // define water planes
  vec3 waterPlaneHigh = vec3(0.0, 0.0, 0.0);
  vec3 waterPlaneLow = vec3(0.0, -WATER_DEPTH, 0.0);

  // define ray origin, moving around
  vec3 origin = vec3(iTime * 0.2, CAMERA_HEIGHT, 1);

  // calculate intersections and reconstruct positions
  float highPlaneHit = intersectPlaneOcean(origin, ray, waterPlaneHigh, vec3(0.0, 1.0, 0.0));
  float lowPlaneHit = intersectPlaneOcean(origin, ray, waterPlaneLow, vec3(0.0, 1.0, 0.0));
  vec3 highHitPos = origin + ray * highPlaneHit;
  vec3 lowHitPos = origin + ray * lowPlaneHit;

  // raymatch water and reconstruct the hit pos
  float dist = raymarchwaterOcean(origin, highHitPos, lowHitPos, WATER_DEPTH);
  vec3 waterHitPos = origin + ray * dist;

  // calculate normalOcean at the hit position
  vec3 N = normalOcean(waterHitPos.xz, 0.01, WATER_DEPTH);

  // smooth the normalOcean with distance to avoid disturbing high frequency noise
  N = mix(N, vec3(0.0, 1.0, 0.0), 0.8 * min(1.0, sqrt(dist*0.01) * 1.1));

  // calculate fresnel coefficient
  float fresnel = (0.04 + (1.0-0.04)*(pow(1.0 - max(0.0, dot(-N, ray)), 5.0)));

  // reflect the ray and make sure it bounces up
  vec3 R = normalize(reflect(ray, N));
  R.y = abs(R.y);
  
  // calculate the reflection and approximate subsurface scattering
  vec3 reflection = getAtmosphereOcean(R) + getSunOcean(R);
  vec3 scattering = vec3(0.0293, 0.0698, 0.1717) * 0.1 * (0.2 + (waterHitPos.y + WATER_DEPTH) / WATER_DEPTH);

  // return the combined result
  vec3 C = fresnel * reflection + scattering;
  color = vec4(aces_tonemapOcean(C * 2.0), 1.0);
  return color;
}
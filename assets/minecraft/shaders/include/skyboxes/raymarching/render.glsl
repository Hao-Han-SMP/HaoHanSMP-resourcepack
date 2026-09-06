// This is just the core code to render the scene
// take a look at "skyboxes/raymarching/scene.glsl" to learn more about actually creating objects to render



// Initialise the render settings
vec3 p = vec3(0);
vec3 rd = worldDirection;
vec3 ro = vec3(0,0,0);

// will be used for lighting
vec3 sunPos = vec3(-10,0,0);

// ENABLE TO BETTER SEE ENDLESS SPACE REPETITION IN ACTION
bool visualizeEndlessSpace = false;

// performance settings
int maxSteps = 80;
float hitDistance = 0.01;
float maxDistance = 100;

if (visualizeEndlessSpace) { maxDistance = 1000; }

// distance tracking
float t = 0;

// the core raymarching loop
for (int i = 0; i < maxSteps;i++) {

    // get the current point to test
    p = ro + rd * t;
    // calculate the distance to the nearest object at that point
    float dist = renderDeptPassRaymarchExample(p);

    // march the ray forward wit the "safe" distance we calculated
    t += dist;

    // exit the loop f an oject has been hit or outisde the bounds
    if (t > maxDistance) {
        t = 0;
        break;
    }
    if (dist < hitDistance) {
        break;
    }
}

// if no object has been hit we can just dispaly a background color
if (t <= 0) {
    fragColor.rgb = vec3(0);
    fragColor.a = 1;
    return;
}

// calculate the surface normal vector
vec3 normal = genNormalRaymarchExample(p);

// object diffuse color
vec3 color = vec3(1);

if (!visualizeEndlessSpace) {
    color *= 1 - t * 0.01;
} else {
    color *= 1 - t * 0.0015;
}


// calculate and mix in lighting
color = applyHarshLight(p,normal,color,sunPos,0.04);
fragColor.a = 1;
fragColor.rgb = color;

// Custom Methods can't be defined in another function so I have to import these functions outisde of the main function scope
// These are accessable from anywhere in the shader so I'm adding the feature name to the function in order to help reduce mistakes


float renderDeptPassRaymarchExample(vec3 point) {
    // initialize a distance tracker
    float dist = 100000;

    // you can render all objects there is a distance function for
    vec3 spherePos = vec3(2,1,0);
    // always return the closest distance
    dist = min(dist,sphereSDF(point - spherePos,0.5));

    // other shapes work too!
    vec3 cubePos = vec3(2,1,-2);
    dist = min(dist,roundBoxSDF(point - cubePos,vec3(0.5),0.2));

    vec3 cube2Pos = vec3(2,3,-2);
    // this will rotate the point around the origin
    vec3 pointCopy = point;
    pointCopy.xz *= rot2D(GameTime * 200);
    dist = min(dist,roundBoxSDF(pointCopy - cube2Pos,vec3(0.5),0.01));

    vec3 cylinderPos = vec3(2,1,2);
    vec3 pointCopy2 = point;
    // if we move the origin we can rotate the hape around itself!
    pointCopy2 -= cylinderPos;
    pointCopy2.xy *= rot2D(GameTime * 1000);
    // also works on multiple axis
    pointCopy2.yz *= rot2D(GameTime * 2000);
    // we need to move the coordiante system back to the original position after rotating
    pointCopy2 += cylinderPos;
    dist = min(dist,cappedCylinderSDF(pointCopy2 - cylinderPos,0.5,0.25));


    vec3 cube4Pos = vec3(sin(GameTime * 1000) * 2,1,4);
    dist = min(dist,sphereSDF(point - cube4Pos,0.5));
    vec3 cube5Pos = vec3(-1,1,4);
    // there are also other mixing functions like a smooth min to merge shapes!
    dist = smin(dist,boxSDF(point - cube5Pos,vec3(0.5)),1);

    vec3 cube6Pos = vec3(0,1,-2);

    // we can also merge from one shape to another by interpolating the distance values
    float sphereDist = sphereSDF(point - cube6Pos,0.5);
    float boxDist = triPrismSDF(point - cube6Pos,vec2(0.25,0.25));
    dist = min(dist,mix(sphereDist,boxDist,(sin(GameTime * 1000) +1) * 0.5));


    vec3 newPoint = point;
    // and lastly, by taking the mod function you can endlessly repeat the fragment of space inside the function
    newPoint = mod(newPoint,30) - 15;

    float vertical = boxSDF(newPoint,vec3(0.5,5,0.5));
    float horizontical = boxSDF(newPoint,vec3(5,0.5,0.5));
    float horizontical2 = boxSDF(newPoint,vec3(0.5,0.5,5));
    float repeatingDistance = smin(smin(vertical,horizontical2,1),horizontical,1);

    // if you want to see this in action properly, enable "visualizeEndlessSpace" in "skyboxes/raymarching/render.glsl" (will cost more performance)

    dist = min(dist,repeatingDistance);

    


    return dist;
}




vec3 genNormalRaymarchExample(vec3 p)
{
    float d = renderDeptPassRaymarchExample(p); //very close to 0
    
    vec2 e = vec2(.01, 0.0);
    vec3 n = vec3
    (
        d - renderDeptPassRaymarchExample(p - e.xyy),
        d - renderDeptPassRaymarchExample(p - e.yxy),
        d - renderDeptPassRaymarchExample(p - e.yyx)
    );
 
  return normalize(n);
}


// more smooth and bright lighting
vec3 applyLight(vec3 p,vec3 normal, vec3 value,vec3 lightPos,float ambientLight) {
    vec3 l = normalize(lightPos-p);

    float difLight = (dot(normal,l) + 0.6) / 1.4;
    difLight = clamp(difLight,ambientLight,1.);
    return value * difLight;
}

// normal light brightness based on impact angle
vec3 applyHarshLight(vec3 p,vec3 normal, vec3 value,vec3 lightPos,float ambientLight) {
    vec3 l = normalize(lightPos-p);

    float difLight = clamp(dot(normal,l),ambientLight,1);
    difLight = clamp(difLight,ambientLight,1.);
    return value * difLight;
}
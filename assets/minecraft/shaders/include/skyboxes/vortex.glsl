// This is a more advanced shader to create a vortex effect in the sky


// Configuration & Style Values
vec3 darkColor1 = rgba(19, 21, 43, 1).rgb;
vec3 darkColor2 = rgba(76, 72, 102, 1).rgb;
vec3 lightColor = rgba(170, 142, 241, 1).rgb;

vec3 eyeColor = vec3(0);
float eyeSize = 0.9;
float eyeSmoothness = 0.35;
float pulse = 0.5;

// alternate full eye settings
// eyeSize = 0.1;
// eyeSmoothness = 0.05;

fragColor.a = 1;


// get world direction yaw
float yaw = atan(worldDirection.r, worldDirection.b) + worldDirection.g + GameTime* 200;
vec2 yawVec = vec2(cos(yaw), sin(yaw));



// sample noise values
float value = voronoiNoise(vec3(yawVec * 10.0, worldDirection.y + GameTime * -2400)).r;
float highlight = clamp(pow(voronoiNoise(vec3(yawVec * 10.0, worldDirection.y + GameTime * -2400)).r,2),0,1);
float light = clamp(pow(voronoiNoise(vec3(yawVec * 10.0, worldDirection.y + GameTime * -1000)).r,2),0.5,0.5);

// apply the noise values with different colors
fragColor.rgb = mix(darkColor1,darkColor2,value * (1 -worldDirection.g));

fragColor.rgb = mix(lightColor * (sin(GameTime * 2400) * pulse  +1.2),fragColor.rgb,1 -highlight *  (1 -worldDirection.g));
fragColor.rgb = mix(lightColor * (sin(GameTime * 2400) * pulse +1.2),fragColor.rgb,1 -0.9 *  (1 -worldDirection.g) * 0.25);

// darken the eye part
float value2 = clamp((worldDirection.g -eyeSize) * 20,0.,20.);
fragColor.rgb = mix(eyeColor,fragColor.rgb,1 -value2 * eyeSmoothness);

// Reapply fog to no mess up underwater visuals
// Modify Vertex Distance to account for very large model sizes (it should no fade out outside of water)
fragColor = applyFog(fragColor,0.25);
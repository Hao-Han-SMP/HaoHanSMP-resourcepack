//Marks the skybox as fully transparent, usually the scase for each skybox
fragColor.a = 1;

// Define two colors to use
vec3 color1 = rgba(168, 212, 172, 1).rgb;
vec3 color2 = rgba(52, 59, 116, 1).rgb;

// Get a smooth noise value from the direction
float scaling = 10;
vec3 offset =  GameTime * vec3(0,-2400,0);
float noiseValue = noise(worldDirection * scaling + offset);


// more advanced example, uncomment to try
noiseValue = noise(worldDirection * scaling + noise(worldDirection * scaling * 2 - noise(worldDirection * scaling * -0.5 + GameTime * -1000) * 5 + GameTime * -500) * 0.5 + GameTime * 500);


//Interpolate between the two colors based on the noise output and save the result as the output
fragColor.rgb = mix(color1,color2,noiseValue);

// Reapply fog to no mess up underwater visuals
// Modify Vertex Distance to account for very large model sizes (it should no fade out outside of water)
fragColor = applyFog(fragColor,0.25);
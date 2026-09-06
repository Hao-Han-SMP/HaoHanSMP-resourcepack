//Marks the skybox as fully transparent, usually the case for each skybox
fragColor.a = 1;

// Define two colors to use
vec3 color2 = rgba(218, 94, 237, 1).rgb;
vec3 color1 = rgba(70, 13, 149, 1).rgb;

// Get a smooth noise value from the direction
float scaling = 10;
float noiseValue = noise(worldDirection * scaling);


// more complex noise, uncomment to try
noiseValue = noise(worldDirection * scaling + noise(worldDirection * scaling * 2 - noise(worldDirection * scaling * -0.5) * 5) * 0.5);


//Interpolate between the two colors based on the noise output and save the result as the output
fragColor.rgb = mix(color1,color2,noiseValue);

// Reapply fog to no mess up underwater visuals
// Modify Vertex Distance to account for very large model sizes (it should no fade out outside of water)
fragColor = applyFog(fragColor,0.25);
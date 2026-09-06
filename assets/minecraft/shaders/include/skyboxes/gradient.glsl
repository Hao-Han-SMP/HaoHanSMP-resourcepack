//Marks the skybox as fully transparent, usually the scase for each skybox
fragColor.a = 1;

// Define two colors to use
vec3 colortop = rgba(168, 212, 212, 1).rgb;
vec3 colorbottom = rgba(52, 56, 116, 1).rgb;

//Interpolate between the two colors based on the y-Direction and save the result as the output
fragColor.rgb = mix(colortop,colorbottom,worldDirection.y);
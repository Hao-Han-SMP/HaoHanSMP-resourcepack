    MODEL_SHADER(1) {
        #moj_import <minecraft:skyboxes/lunar.glsl>
        return;
    }
    MODEL_SHADER(2) {
        #moj_import <minecraft:skyboxes/noise.glsl>
        return;
    }

    MODEL_SHADER(3) {
        #moj_import <minecraft:skyboxes/animation.glsl>
        return;
    }
    MODEL_SHADER(4) {
        #moj_import <minecraft:skyboxes/raymarching/render.glsl>
        return;
    }

    MODEL_SHADER(5) {
        fragColor = mainImageOcean(worldDirection);
        fragColor = applyFog(fragColor, 0.25);
        return;
    }
    MODEL_SHADER(6) {
        #moj_import <minecraft:skyboxes/vortex.glsl>
        return;
    }

    MODEL_SHADER(7) {
        #moj_import <minecraft:skyboxes/lunar.glsl>
        return;
    }

    MODEL_SHADER(8) {
        #moj_import <minecraft:skyboxes/lunar.glsl>
        return;
    }

    MODEL_SHADER(9) {
        // Original From https://polyhaven.com/a/kloofendal_48d_partly_cloudy_puresky licensed under CC0
        // Downscaled to reduce files size, however an 8k texture would also work
        vec2 textureSize = vec2(1024, 512);
        
        vec2 sphericalUV = normalToSpherical(worldDirection);
        vec2 atlasUV = localTextureUV(textureSize, sphericalUV);
        fragColor = texture(Sampler0, atlasUV);

        fragColor.a = 1;
        fragColor = applyFog(fragColor, 0.25);
        return; 
    }

//
//  kernel_imageAlphaBlending.metal
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/02.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

#include <metal_stdlib>
#include <metal_common>
#include <simd/simd.h>
#import "../../include/MCShaderTypes.h"
#import "../Shader.metal"

using namespace metal;

namespace imageBlending {
    kernel void kernel_imageBlending_alphaBlending(texture2d<float, access::read> originalTexture [[texture(OriginalTextureIndex)]],
                                          texture2d<float, access::read> overTexture [[texture(OverTextureIndex)]],
                                          texture2d<float, access::write> destinationTexture [[texture(DestinationTextureIndex)]],
                                          uint2 gid [[thread_position_in_grid]])
    {
        float4 originalColor = originalTexture.read(gid);
        float4 overColor = overTexture.read(gid);
        float4 resultColor = float4((originalColor.rgb * (1.0 - overColor.a)) + overColor.rgb, 1.0);
        
        destinationTexture.write(resultColor, gid);
    }
}

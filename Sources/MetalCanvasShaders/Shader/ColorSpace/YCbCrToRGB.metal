//
//  YCbCrToRGB.metal
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/03.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

#include <metal_stdlib>
#include <metal_common>
#include <simd/simd.h>
#import "../../include/MCShaderTypes.h"
#import "../Shader.metal"

using namespace metal;

namespace ColorSpace {
    vertex ImageColorInOut vertex_YCbCrToRGB(const device MCVertexIn *in [[ buffer(MCVertexIndex) ]],
                                             uint vid [[ vertex_id ]])
    {
        ImageColorInOut out;
        out.position = in[vid].position;
        out.texCoords = in[vid].texCoords;
        return out;
    }

    fragment float4 fragment_YCbCrToRGB(ImageColorInOut in [[stage_in]],
                                        texture2d<float, access::sample> capturedImageTextureY [[ texture(0) ]],
                                        texture2d<float, access::sample> capturedImageTextureCbCr [[ texture(1) ]])
    {
        
        constexpr sampler colorSampler(mip_filter::linear,
                                       mag_filter::linear,
                                       min_filter::linear);
        
        const float4x4 ycbcrToRGBTransform = float4x4(
                                                      float4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
                                                      float4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
                                                      float4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
                                                      float4(-0.7010f, +0.5291f, -0.8860f, +1.0000f)
                                                      );
        
        // Sample Y and CbCr textures to get the YCbCr color at the given texture coordinate
        float4 ycbcr = float4(capturedImageTextureY.sample(colorSampler, in.texCoords).r,
                              capturedImageTextureCbCr.sample(colorSampler, in.texCoords).rg, 1.0);
        
        // Return converted RGB color
        return ycbcrToRGBTransform * ycbcr;
    }

    ////////////////////////////////////////////////
    kernel void kernel_YCbCrToRGB(texture2d<float, access::sample> capturedImageTextureY [[texture(OriginalTextureIndex)]],
                                  texture2d<float, access::sample> capturedImageTextureCbCr [[texture(OverTextureIndex)]],
                                  texture2d<float, access::write> destinationTexture [[texture(DestinationTextureIndex)]],
                                  uint2 gid [[thread_position_in_grid]])
    {

        constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
        
        const float4x4 ycbcrToRGBTransform = float4x4(
                                                      float4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
                                                      float4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
                                                      float4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
                                                      float4(-0.7010f, +0.5291f, -0.8860f, +1.0000f)
                                                      );
        
        float4 textureYColor = capturedImageTextureY.read(gid);
        float4 textureCbCrColor = capturedImageTextureCbCr.read(gid);
        float4 ycbcr = float4(textureYColor.r, textureCbCrColor.r, textureCbCrColor.g, 1.0);
        destinationTexture.write(ycbcrToRGBTransform * ycbcr, gid);
    }
}

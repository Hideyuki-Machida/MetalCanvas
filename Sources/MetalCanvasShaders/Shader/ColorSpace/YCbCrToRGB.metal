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

    float4 YCbCrToRGBYCbCr(float4 sorceYColor, float4 sorceCbCrColor) {
        const float4x4 ycbcrToRGBTransform = float4x4(
                                                      float4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
                                                      float4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
                                                      float4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
                                                      float4(-0.7010f, +0.5291f, -0.8860f, +1.0000f)
                                                      );
        float4 ycbcr = float4(sorceYColor.r, sorceCbCrColor.r, sorceCbCrColor.g, 1.0);
        return ycbcrToRGBTransform * ycbcr;
    }
    
    ////////////////////////////////////////////////
    kernel void kernel_YCbCrToRGB(texture2d<float, access::sample> sorceY [[texture(0)]],
                                  texture2d<float, access::sample> sorceCbCr [[texture(1)]],
                                  texture2d<float, access::write> destinationRGB [[texture(2)]],
                                  uint2 gid [[thread_position_in_grid]])
    {

        constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
        
        float4 sorceYColor = sorceY.read(gid);
        float4 sorceCbCrColor = sorceCbCr.read(gid);
        float4 RGB = YCbCrToRGBYCbCr(sorceYColor, sorceCbCrColor);
        destinationRGB.write(RGB, gid);
    }

    ////////////////////////////////////////////////
    kernel void kernel_YCbCrToRGBYCbCr(texture2d<float, access::sample> sorceY [[texture(0)]],
                                       texture2d<float, access::sample> sorceCbCr [[texture(1)]],
                                       texture2d<float, access::write> destinationRGB [[texture(2)]],
                                       texture2d<float, access::write> destinationY [[texture(3)]],
                                       texture2d<float, access::write> destinationCb [[texture(4)]],
                                       texture2d<float, access::write> destinationCr [[texture(5)]],
                                       uint2 gid [[thread_position_in_grid]])
    {

        constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
        
        const float4x4 ycbcrToRGBTransform = float4x4(
                                                      float4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
                                                      float4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
                                                      float4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
                                                      float4(-0.7010f, +0.5291f, -0.8860f, +1.0000f)
                                                      );

        float4 textureYColor = sorceY.read(gid);
        float4 textureCbCrColor = sorceCbCr.read(gid);
        float4 ycbcr = float4(textureYColor.r, textureCbCrColor.r, textureCbCrColor.g, 1.0);
        destinationRGB.write(ycbcrToRGBTransform * ycbcr, gid);

        /*
        float4 sorceYColor = sorceY.read(gid);
        float4 sorceCbCrColor = sorceCbCr.read(gid);
        float4 RGB = YCbCrToRGBYCbCr(sorceYColor, sorceCbCrColor);
        destinationRGB.write(RGB, gid);
        
        float Y = sorceYColor.r;
        destinationY.write(float4(Y, Y, Y, 1.0f), gid);

        float Cb = sorceCbCrColor.g;
        destinationCb.write(float4(Cb, Cb, Cb, 1.0f), gid);

        float Cr = sorceCbCrColor.r;
        destinationCr.write(float4(Cr, Cr, Cr, 1.0f), gid);
         */
    }
}

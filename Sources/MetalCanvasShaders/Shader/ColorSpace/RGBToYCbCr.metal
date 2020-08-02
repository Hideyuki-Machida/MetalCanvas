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
    kernel void kernel_RGBToYCbCr(texture2d<float, access::sample> sorceRGB [[texture(0)]],
                                  texture2d<float, access::write> destinationY [[texture(1)]],
                                  texture2d<float, access::write> destinationCb [[texture(2)]],
                                  texture2d<float, access::write> destinationCr [[texture(3)]],
                                  uint2 gid [[thread_position_in_grid]])
    {
        constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);

        float4 sorceRGBColor = sorceRGB.read(gid);

        float offSet = (128.0f / 255.0f);
        float Y = (0.299f * sorceRGBColor.r) + (0.587f * sorceRGBColor.g) + (0.114f * sorceRGBColor.b);
        float Cb = (-0.1687f * sorceRGBColor.r) - (0.331f * sorceRGBColor.g) + (0.500f * sorceRGBColor.b) + offSet;
        float Cr = (0.5f * sorceRGBColor.r) - (0.419f * sorceRGBColor.g) + (0.081f * sorceRGBColor.b) + offSet;

        destinationY.write(float4(Y, Y, Y, 1.0f), gid);
        destinationCb.write(float4(Cb, Cb, Cb, 1.0f), gid);
        destinationCr.write(float4(Cr, Cr, Cr, 1.0f), gid);
    }
}

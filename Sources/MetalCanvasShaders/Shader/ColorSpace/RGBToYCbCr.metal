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
        uint2 gidCbCr = uint2(gid.x / 2, gid.y / 2);

        float Y = (0.257 * sorceRGBColor.r) + (0.504 * sorceRGBColor.g) + (0.098 * sorceRGBColor.b) + (16.0 / 255.0);
        float Cb = (-0.148 * sorceRGBColor.r) - (0.291 * sorceRGBColor.g) + (0.439 * sorceRGBColor.b) + (128.0/ 255.0);
        float Cr = (0.439 * sorceRGBColor.r) - (0.368 * sorceRGBColor.g) - (0.071 * sorceRGBColor.b) + (128.0/ 255.0);

        destinationY.write(float4(Y, Y, Y, 1.0f), gid);
        destinationCb.write(float4(Cb, 0.0, 0.0, 1.0), gidCbCr);
        destinationCr.write(float4(0.0, Cr, 0.0, 1.0), gidCbCr);
    }
}

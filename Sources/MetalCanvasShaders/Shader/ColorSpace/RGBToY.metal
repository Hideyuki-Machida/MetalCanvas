//
//  RGBToY.metal
//  MetalCanvas
//
//  Created by hideyuki machida on 2020/10/04.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

#include <metal_stdlib>
#include <metal_common>
#include <simd/simd.h>
#import "../../include/MCShaderTypes.h"
#import "../Shader.metal"

using namespace metal;

namespace ColorSpace {
    kernel void kernel_RGBToY(texture2d<float, access::sample> sorceRGB [[texture(0)]],
                              texture2d<float, access::write> destinationY [[texture(1)]],
                              uint2 gid [[thread_position_in_grid]])
    {
        float4 sorceRGBColor = sorceRGB.read(gid);
        float Y = (0.299f * sorceRGBColor.r) + (0.587f * sorceRGBColor.g) + (0.114f * sorceRGBColor.b);
        destinationY.write(float4(Y, Y, Y, 1.0f), gid);
    }
}

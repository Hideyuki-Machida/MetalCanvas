//
//  Triangle.metal
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/05/15.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

#include <metal_stdlib>
#include <metal_common>
#include <simd/simd.h>
#import "../../MCShaderTypes.h"
#import "../../MetalShaderType.metal"

using namespace metal;

namespace primitive {
    vertex TriangleColorInOut vertex_primitive_triangle(const device MCPrimmitiveVertexIn *in [[ buffer(MCVertexIndex) ]],
                                                        const device float4x4 &projectionMatrix [[buffer(MCProjectionMatrixIndex)]],
                                                        unsigned int vid [[vertex_id]])
    {
        float4x4 mat = projectionMatrix;
        float4 pos = in[vid].position;

        TriangleColorInOut out;
        out.position = mat * pos;
        out.color = in[vid].color;
        return out;
    }

    fragment float4 fragment_primitive_triangle(TriangleColorInOut in [[ stage_in ]])
    {
        return in.color;
    }
}

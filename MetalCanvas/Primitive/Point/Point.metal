//
//  Point.metal
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/02.
//  Copyright © 2019 Donuts. All rights reserved.
//

#include <metal_stdlib>
#include <metal_common>
#include <simd/simd.h>
#import "../../MCShaderTypes.h"
#import "../../MetalShaderType.metal"

using namespace metal;

namespace primitive {
    vertex PointVertexOut vertex_primitive_points(constant packed_float3 *vertex_array [[buffer(MCVertexIndex)]],
                                                 const device float4 &colors [[buffer(MCColorIndex)]],
                                                 const device float &size [[buffer(MCSizeIndex)]],
                                                 const device float4x4 &projectionMatrix [[buffer(MCProjectionMatrixIndex)]],
                                                 unsigned int vid [[vertex_id]]) {
        
        float4x4 mat = projectionMatrix;
        float4 pos = float4(vertex_array[vid], 1.0);
        
        PointVertexOut out;
        out.pos = mat * pos;
        out.pointSize = size;
        out.color = colors;
        return out;
    }
    
    fragment half4 fragment_primitive_points(PointVertexOut in [[stage_in]]) {
        return half4(in.color.rgba);
    }

    vertex PointVertexOut vertex_primitive_point(constant MCPointIn *vertex_array [[buffer(MCVertexIndex)]],
                                                 const device float4x4 &projectionMatrix [[buffer(MCProjectionMatrixIndex)]],
                                                 unsigned int vid [[vertex_id]]) {
        
        float4x4 mat = projectionMatrix;
        float4 pos = float4(vertex_array[vid].position, 1.0);
        
        PointVertexOut out;
        out.pos = mat * pos;
        out.pointSize = vertex_array[vid].size;
        out.color = vertex_array[vid].color;
        return out;
    }
    
    fragment half4 fragment_primitive_point(PointVertexOut in [[stage_in]]) {
        return half4(in.color.rgba);
    }
}

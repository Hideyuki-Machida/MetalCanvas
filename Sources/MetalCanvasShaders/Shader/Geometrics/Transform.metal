//
//  File.swift
//  
//
//  Created by hideyuki machida on 2020/10/04.
//

#include <metal_stdlib>
#include <metal_common>
#include <simd/simd.h>
#import "../../include/MCShaderTypes.h"
#import "../Shader.metal"

using namespace metal;

namespace Geometrics {
    vertex ImageColorInOut vertex_Transform(const device MCVertexIn *in [[ buffer(0) ]],
                                                  const device float4x4 &projectionMat [[buffer(1)]],
                                                  const device float4x4 &objMat [[buffer(2)]],
                                                  uint vid [[ vertex_id ]])
    {
        float4x4 mat = projectionMat * objMat;

        ImageColorInOut out;
        out.position = mat * in[vid].position;
        out.texCoords = in[vid].texCoords;
        return out;
    }

    fragment float4 fragment_Transform(ImageColorInOut in [[ stage_in ]],
                                             texture2d<float> texture [[ texture(0) ]])
    {
        constexpr sampler colorSampler;
        float4 color = texture.sample(colorSampler, in.texCoords);
        return color;
    }
}

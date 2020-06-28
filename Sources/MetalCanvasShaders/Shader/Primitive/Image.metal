//
//  Image.metal
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

namespace primitive {
    vertex ImageColorInOut vertex_primitive_image(const device MCVertexIn *in [[ buffer(MCVertexIndex) ]],
                                                  const device float4x4 &projectionMat [[buffer(MCProjectionMatrixIndex)]],
                                                  const device float4x4 &objMat [[buffer(30)]],
                                                  uint vid [[ vertex_id ]])
    {
        float4x4 mat = projectionMat * objMat;
        
        ImageColorInOut out;
        out.position = mat * in[vid].position;
        out.texCoords = in[vid].texCoords;
        return out;
    }
    
    fragment float4 fragment_primitive_image(ImageColorInOut in [[ stage_in ]],
                                             texture2d<float> texture [[ texture(0) ]])
    {
        constexpr sampler colorSampler;
        float4 color = texture.sample(colorSampler, in.texCoords);
        return color;
    }
}

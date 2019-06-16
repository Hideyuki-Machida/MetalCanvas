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
#import "../Shader.metal"

using namespace metal;

namespace primitive {
	vertex TriangleColorInOut vertex_primitive_triangle(constant packed_float3 *vertex_array [[buffer(MCVertexIndex)]],
													  const device float4 &colors [[buffer(MCColorIndex)]],
													  const device float4x4 &projectionMatrix [[buffer(MCProjectionMatrixIndex)]],
													  unsigned int vid [[vertex_id]])
	{
		float4x4 mat = projectionMatrix;
		float4 pos = float4(vertex_array[vid], 1.0);
		
		TriangleColorInOut out;
		out.position = mat * pos;
		out.color = colors;
		return out;
	}
	
	fragment float4 fragment_primitive_triangle(TriangleColorInOut in [[ stage_in ]],
											 texture2d<float> texture [[ texture(0) ]])
	{
		return in.color.rgba;
	}
}

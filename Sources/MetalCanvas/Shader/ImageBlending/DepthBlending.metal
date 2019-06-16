//
//  DepthBlending.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/18.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

#include <metal_stdlib>
#include <metal_common>
#include <simd/simd.h>
#import "../../MCShaderTypes.h"
#import "../Shader.metal"

using namespace metal;

namespace imageBlending {
	////////////////////////////////////////////////
	kernel void kernel_imageBlending_depthBlending(texture2d<float, access::read> originalTexture [[texture(OriginalTextureIndex)]],
		texture2d<float, access::read> overTexture [[texture(OverTextureIndex)]],
		texture2d<float, access::write> destinationTexture [[texture(DestinationTextureIndex)]],
		uint2 gid [[thread_position_in_grid]])
	{
		float4 originalColor = originalTexture.read(gid);
		float4 overColor = overTexture.read(gid);
		
		//float3 normal = normalize(overColor.rgb);
		//float4 black = float4(1.0, 0.0, 0.0, 1.0);
		//float a = (normal.r + normal.g + normal.b) / 3.0;
		float a = (overColor.r + overColor.g + overColor.b) / 3.0;
		//float4 resultColor = float4((originalColor.rgb * (1.0 - normal)) + black.rgb, 1.0);
		//float4 resultColor = float4((originalColor.rgb * (normal)) + overColor.rgb, 1.0);
		//float4 resultColor = float4((black.rgb * (normal)) + originalColor.rgb, 1.0);
		//float4 resultColor = float4((originalColor.rgb * (1.0 - overColor.a)) + overColor.rgb, 1.0);
		
		float4 resultColor = float4((originalColor.rgb * (1.0 - a)), 1.0);
		
		destinationTexture.write(resultColor, gid);
	}
}

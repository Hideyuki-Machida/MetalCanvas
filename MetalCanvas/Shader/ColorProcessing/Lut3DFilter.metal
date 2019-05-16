//
//  LutFilter.metal
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/02/25.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

#include <metal_stdlib>
#include <metal_common>
#include <simd/simd.h>
#import "../../MCShaderTypes.h"
#import "../Shader.metal"

using namespace metal;

typedef struct
{
	float intensity;
} IntensityUniform;

vertex ImageColorInOut vertex_Lut3DFilter(device float4 *positions [[ buffer(MCVertexIndex) ]],
										 device float2 *texCoords [[ buffer(MCTexCoord) ]],
										 uint vid [[ vertex_id ]])
{
	ImageColorInOut out;
	out.position = positions[vid];
	out.texCoords = texCoords[vid];
	return out;
}

fragment half4 fragment_Lut3DFilter(ImageColorInOut in [[stage_in]],
								   texture2d<half> originalTexture [[texture(OriginalTextureIndex)]],
								   texture2d<half> lutTexture [[texture(1)]])
								   //constant IntensityUniform& uniform [[ buffer(1) ]])
{
	constexpr sampler quadSampler;
	half4 base = originalTexture.sample(quadSampler, in.texCoords);
	
	half blueColor = base.b * 63.0h;
	
	half2 quad1;
	quad1.y = floor(floor(blueColor) / 8.0h);
	quad1.x = floor(blueColor) - (quad1.y * 8.0h);
	
	half2 quad2;
	quad2.y = floor(ceil(blueColor) / 8.0h);
	quad2.x = ceil(blueColor) - (quad2.y * 8.0h);
	
	float2 texPos1;
	texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.r);
	texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.g);
	
	float2 texPos2;
	texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.r);
	texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.g);
	
	constexpr sampler quadSampler3;
	half4 newColor1 = lutTexture.sample(quadSampler3, texPos1);
	constexpr sampler quadSampler4;
	half4 newColor2 = lutTexture.sample(quadSampler4, texPos2);
	
	half4 newColor = mix(newColor1, newColor2, fract(blueColor));

	return half4(mix(base, half4(newColor.rgb, base.w), half(1.0)));
	//return half4(mix(base, half4(newColor.rgb, base.w), half(uniform.intensity)));
}


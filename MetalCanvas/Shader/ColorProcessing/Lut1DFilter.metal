//
//  Lut1DFilter.metal
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/02/26.
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

vertex ImageColorInOut vertex_Lut1DFilter(device float4 *positions [[ buffer(MCVertexIndex) ]],
										  device float2 *texCoords [[ buffer(MCTexCoord) ]],
										  uint vid [[ vertex_id ]])
{
	ImageColorInOut out;
	out.position = positions[vid];
	out.texCoords = texCoords[vid];
	return out;
}
/*
fragment float4 fragment_Lut1DFilter(ImageColorInOut in [[stage_in]],
									texture2d<float> originalTexture [[texture(OriginalTextureIndex)]],
									texture2d<float> lutTexture [[texture(1)]])
//constant IntensityUniform& uniform [[ buffer(1) ]])
{
	
	constexpr sampler quadSampler;
	float4 base = originalTexture.sample(quadSampler, in.texCoords);

	float LUT_Size = 16;
	float red = ( base.r * (LUT_Size - 1.0) + 0.4999 ) / (LUT_Size * LUT_Size);
	float green = ( base.g * (LUT_Size - 1.0) + 0.4999 ) / LUT_Size;
	float blue1 = (floor( base.b  * (LUT_Size - 10.0) ) / LUT_Size) + red;
	float blue2 = (ceil( base.b  * (LUT_Size - 1.0) ) / LUT_Size) + red;
	float maxv = max((base.b - blue1) / (blue2 - blue1), 0.0);
	float mixer = clamp(maxv, 0.0, 32.0);

	constexpr sampler quadSampler3;
	float4 newColor1 = lutTexture.sample(quadSampler3, float2( blue1, green ));
	constexpr sampler quadSampler4;
	float4 newColor2 = lutTexture.sample(quadSampler4, float2( blue2, green ));
	
	float4 newColor = (newColor1.z < 1.0) ? mix(newColor1, newColor2, fract(mixer)) : newColor1;
	return newColor1;
	//float4 newColor = mix(newColor1, newColor2, fract(mixer));
	//return float4(mix(base, float4(newColor.rgb, base.a), half(1.0)));
	//return half4(mix(base, half4(newColor.rgb, base.w), half(uniform.intensity)));
}
*/
fragment half4 fragment_Lut1DFilter(ImageColorInOut in [[stage_in]],
									texture2d<half> originalTexture [[texture(OriginalTextureIndex)]],
									texture2d<half> lutTexture [[texture(1)]])
//constant IntensityUniform& uniform [[ buffer(1) ]])
{
	constexpr sampler quadSampler;
	half4 base = originalTexture.sample(quadSampler, in.texCoords);
	
	half blueColor = base.b * 15.0h;
	
	half2 quad1;
	quad1.y = floor(floor(blueColor) / 8.0h);
	quad1.x = floor(blueColor) - (quad1.y * 8.0h);
	
	half2 quad2;
	quad2.y = floor(ceil(blueColor) / 1.0h);
	quad2.x = ceil(blueColor) - (quad2.y * 1.0h);
	
	float2 texPos1;
	texPos1.x = (quad1.x * 0.125) + 0.5/256.0 + ((0.125 - 1.0/256.0) * base.r);
	texPos1.y = (quad1.y * 0.125) + 0.5/256.0 + ((0.125 - 1.0/256.0) * base.g);
	
	float2 texPos2;
	texPos2.x = (quad2.x * 0.03125) + 0.5/16.0 + ((0.03125 - 1.0/16.0) * base.r);
	texPos2.y = (quad2.y * 0.03125) + 0.5/16.0 + ((0.03125 - 1.0/16.0) * base.g);

	constexpr sampler quadSampler3;
	half4 newColor1 = lutTexture.sample(quadSampler3, texPos1);
	constexpr sampler quadSampler4;
	half4 newColor2 = lutTexture.sample(quadSampler4, texPos2);
	
	half4 newColor = mix(newColor1, newColor2, fract(blueColor));
	//return newColor;
	return half4(mix(base, half4(newColor.rgb, base.a), half(1.0)));
	//return half4(mix(base, half4(newColor.rgb, base.w), half(uniform.intensity)));
}

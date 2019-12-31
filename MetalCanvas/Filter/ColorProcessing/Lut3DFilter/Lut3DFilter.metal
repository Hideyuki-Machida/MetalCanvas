//
//  LutFilter.metal
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/02/25.
//  Copyright © 2019 Donuts. All rights reserved.
//

#include <metal_stdlib>
#include <metal_common>
#include <simd/simd.h>
#import "../../../MCShaderTypes.h"
#import "../../../MetalShaderType.metal"

using namespace metal;

namespace ColorProcessing {
    vertex ImageColorInOut vertex_Lut3DFilter(const device MCVertexIn *in [[ buffer(MCVertexIndex) ]],
                                              uint vid [[ vertex_id ]])
    {
        ImageColorInOut out;
        out.position = in[vid].position;
        out.texCoords = in[vid].texCoords;
        return out;
    }

    fragment half4 fragment_Lut3DFilter(ImageColorInOut in [[stage_in]],
                                        texture2d<half> originalTexture [[texture(OriginalTextureIndex)]],
                                        texture2d<half> lutTexture [[texture(1)]],
                                        constant float &intensity [[ buffer(MCIntensity) ]])
    {
        constexpr sampler quadSampler;
        half4 color = originalTexture.sample(quadSampler, in.texCoords);
        
        half blueColor = color.b * 63.0h;
        
        half2 quad1;
        quad1.y = floor(floor(blueColor) / 8.0h);
        quad1.x = floor(blueColor) - (quad1.y * 8.0h);
        
        half2 quad2;
        quad2.y = floor(ceil(blueColor) / 8.0h);
        quad2.x = ceil(blueColor) - (quad2.y * 8.0h);
        
        float2 texPos1;
        texPos1.x = (quad1.x * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * color.r);
        texPos1.y = (quad1.y * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * color.g);
        
        float2 texPos2;
        texPos2.x = (quad2.x * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * color.r);
        texPos2.y = (quad2.y * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * color.g);
        
        half4 newColor1 = lutTexture.sample(quadSampler, texPos1);
        half4 newColor2 = lutTexture.sample(quadSampler, texPos2);
        
        half4 newColor = mix(newColor1, newColor2, fract(blueColor));

        return half4(mix(color, half4(newColor.rgb, color.w), half(intensity)));
    }
}

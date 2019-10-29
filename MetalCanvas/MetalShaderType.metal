//
//  test.metal
//  CameraCore
//
//  Created by hideyuki machida on 2018/10/19.
//  Copyright © 2018 町田 秀行. All rights reserved.
//

#include <metal_stdlib>
#include <metal_common>
#include <simd/simd.h>
#import "MCShaderTypes.h"

using namespace metal;

////////////////////////////////////////////////
struct PointVertexOut{
    float4 pos [[position]];
    float pointSize [[point_size]];
    float4 color;
};

////////////////////////////////////////////////
struct ImageColorInOut {
    float4 position [[ position ]];
    float2 texCoords;
};

////////////////////////////////////////////////
struct TriangleColorInOut {
    float4 position [[ position ]];
    float4 color;
};

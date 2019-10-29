//
//  MCShaderTypes.h
//  CameraCore
//
//  Created by hideyuki machida on 2018/12/25.
//  Copyright © 2018 町田 秀行. All rights reserved.
//

#ifndef MCShaderTypes_h
#define MCShaderTypes_h

#include <simd/simd.h>

typedef enum VertexInputIndex
{
    MCProjectionMatrixIndex = 0,
    MCVertexIndex = 1,
    MCColorIndex = 2,
    MCSizeIndex = 3,
    MCTexCoord = 4,
    MCIntensity = 5,
} VertexInputIndex;

typedef enum KernelImageBlendingInputIndex
{
    OriginalTextureIndex = 0,
    OverTextureIndex = 1,
    DestinationTextureIndex = 2,
} KernelImageBlendingInputIndex;

typedef struct
{
    vector_float3 position;
    vector_float4 color;
    float size;
} MCPoint;

typedef struct
{
    vector_float3 position;
    vector_float4 color;
} MCLine;

typedef struct
{
    vector_float4 position;
    vector_float2 texCoords;
} MCVertexIn;

typedef struct
{
    vector_float4 position;
    vector_float4 color;
} MCPrimmitiveVertexIn;

typedef struct
{
    matrix_float4x4 projectionMat;
    matrix_float4x4 objectMat;
} MCMatrixIn;


#endif /* MTLCTypes_h */

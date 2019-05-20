//
//  MCShaderTypes.h
//  CameraCore
//
//  Created by hideyuki machida on 2018/12/25.
//  Copyright © 2018 町田 秀行. All rights reserved.
//

#ifndef MCShaderTypes_h
#define MCShaderTypes_h

//#import <Foundation/Foundation.h>
#include <simd/simd.h>

typedef enum VertexInputIndex
{
	MCProjectionMatrixIndex = 0,
	MCVertexIndex = 1,
	MCColorIndex = 2,
	MCSizeIndex = 3,
	MCTexCoord = 4,
} VertexInputIndex;

typedef enum KernelImageBlendingInputIndex
{
	OriginalTextureIndex = 0,
	OverTextureIndex = 1,
	DestinationTextureIndex = 2,
} KernelImageBlendingInputIndex;

/*
typedef struct
{
	float r;
	float g;
	float b;
	float a;
} MTLCColor;
*/
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


#endif /* MTLCTypes_h */

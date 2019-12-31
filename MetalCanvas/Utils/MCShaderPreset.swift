//
//  MetalShaderType.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/10/27.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation

public struct MCShaderPreset {
    public static let normalizedVertex: [MCVertexIn] = [
        MCVertexIn(position: SIMD4<Float>(-1, -1, 0, 1), texCoords: SIMD2<Float>(0, 1)),
        MCVertexIn(position: SIMD4<Float>(1, -1, 0, 1), texCoords: SIMD2<Float>(1, 1)),
        MCVertexIn(position: SIMD4<Float>(-1, 1, 0, 1), texCoords: SIMD2<Float>(0, 0)),
        MCVertexIn(position: SIMD4<Float>(1, 1, 0, 1), texCoords: SIMD2<Float>(1, 0)),
    ]
}

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
        MCVertexIn.init(position: SIMD4<Float>.init(-1, -1, 0, 1), texCoords: SIMD2<Float>.init(0, 1)),
        MCVertexIn.init(position: SIMD4<Float>.init(1, -1, 0, 1), texCoords: SIMD2<Float>.init(1, 1)),
        MCVertexIn.init(position: SIMD4<Float>.init(-1, 1, 0, 1), texCoords: SIMD2<Float>.init(0, 0)),
        MCVertexIn.init(position: SIMD4<Float>.init(1, 1, 0, 1), texCoords: SIMD2<Float>.init(1, 0)),
    ]
}

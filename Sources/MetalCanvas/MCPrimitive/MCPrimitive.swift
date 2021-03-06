//
//  MCPrimitive.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/03.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation
import Metal

public struct MCPrimitive {
    private init() {} /* このstructはnamespace用途なのでインスタンス化防止 */

    public enum ErrorType: Error {
        case setupError
        case drawError
        case endError
    }

    public enum Anchor {
        case topLeft
        case bottomLeft
        case center
    }

    public struct DrawInfo {
        var renderPassDescriptor: MTLRenderPassDescriptor
        var renderSize: MCSize
        var orthoType: MCCanvas.OrthoType
        var projectionMatrixBuffer: MTLBuffer

        public init(renderPassDescriptor: MTLRenderPassDescriptor, renderSize: MCSize, orthoType: MCCanvas.OrthoType, projectionMatrixBuffer: MTLBuffer) {
            self.renderPassDescriptor = renderPassDescriptor
            self.renderSize = renderSize
            self.orthoType = orthoType
            self.projectionMatrixBuffer = projectionMatrixBuffer
        }
    }
}

//
//  MCPrimitiveNameSpace.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/03.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation

public struct MCPrimitive {

    public enum ErrorType: Error {
        case setupError
        case drawError
        case endError
    }

    public enum anchor {
        case topLeft
        case bottomLeft
        case center
    }
    public struct DrawInfo {
        var renderPassDescriptor: MTLRenderPassDescriptor
        var renderSize: CGSize
        var orthoType: MCCanvas.OrthoType
        var projectionMatrixBuffer: MTLBuffer
        
        public init(renderPassDescriptor: MTLRenderPassDescriptor, renderSize: CGSize, orthoType: MCCanvas.OrthoType, projectionMatrixBuffer: MTLBuffer) {
            self.renderPassDescriptor = renderPassDescriptor
            self.renderSize = renderSize
            self.orthoType = orthoType
            self.projectionMatrixBuffer = projectionMatrixBuffer
        }
    }
}

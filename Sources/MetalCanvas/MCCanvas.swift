//
//  MCCanvas.swift
//  CameraCore
//
//  Created by hideyuki machida on 2018/12/23.
//  Copyright © 2018 hideyuki machida. All rights reserved.
//

import Foundation
import Metal
import CoreVideo
import GraphicsLibs_Swift
import GLKit

public class MCCanvas {
    public enum ErrorType: Error {
        case setupError
        case drawError
        case endError
    }

    public enum OrthoType {
        case perspective
        case center
        case topLeft
        case bottomLeft

        func getMatrix(size: CGSize) -> GLKMatrix4 {
            switch self {
            case .perspective: return MCGeom.Matrix4x4().glkMatrix
            case .center: return GLKMatrix4MakeOrtho(-Float(size.width / 2), Float(size.width / 2), Float(size.height / 2), -Float(size.height / 2), -1, 1)
            case .topLeft: return GLKMatrix4MakeOrtho(0, Float(size.width), Float(size.height), 0, -1, 1)
            case .bottomLeft: return GLKMatrix4MakeOrtho(0, Float(size.width), 0, Float(size.height), -1, 1)
            }
        }

        /*
        func getMatrix(size: MCSize) -> MCGeom.Matrix4x4 {
            switch self {
            case .perspective: return MCGeom.Matrix4x4()
            case .center: return MCGeom.Matrix4x4.Ortho(left: -Float(size.w / 2), right: Float(size.w / 2), bottom: Float(size.h / 2), top: -Float(size.h / 2), nearZ: -1, farZ: 1)
            case .topLeft: return MCGeom.Matrix4x4.Ortho(left: 0, right: Float(size.w), bottom: Float(size.h), top: 0, nearZ: -1, farZ: 1)
            case .bottomLeft: return MCGeom.Matrix4x4.Ortho(left: 0, right: Float(size.w), bottom: 0, top: Float(size.h), nearZ: -1, farZ: 1)
            }
        }
         */
    }

    private var projection: MCGeom.Matrix4x4 = MCGeom.Matrix4x4()
    public private(set) var drawInfo: MCPrimitive.DrawInfo
    public var mcTexture: MCTexture
    public var texture: MTLTexture? {
        return drawInfo.renderPassDescriptor.colorAttachments[0].texture
    }

    public init(destination: inout MCTexture, orthoType: OrthoType, loadAction: MTLLoadAction = MTLLoadAction.load) throws {
        self.mcTexture = destination
        /*
        let renderSize: MCSize = MCSize(w: destination.size.w, h: destination.size.h)
        self.projection = orthoType.getMatrix(size: renderSize)
*/
        self.mcTexture = destination
        let renderSize: MCSize = MCSize(w: destination.size.w, h: destination.size.h)
        self.projection.glkMatrix = orthoType.getMatrix(size: renderSize.toCGSize())

        let renderPassDescriptor: MTLRenderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].loadAction = loadAction
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreAction.store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        renderPassDescriptor.colorAttachments[0].texture = destination.texture

        let projectionMatrixBuffer: MTLBuffer = try MCCore.makeBuffer(data: self.projection.raw)
        self.drawInfo = MCPrimitive.DrawInfo(
            renderPassDescriptor: renderPassDescriptor,
            renderSize: renderSize,
            orthoType: orthoType,
            projectionMatrixBuffer: projectionMatrixBuffer
        )
    }

    public convenience init(orthoType: OrthoType, renderSize: CGSize, loadAction: MTLLoadAction = MTLLoadAction.load) throws {
        guard let pixelBuffer: CVPixelBuffer = CVPixelBuffer.create(size: renderSize) else { throw ErrorType.setupError }
        var texture: MCTexture = try MCTexture(pixelBuffer: pixelBuffer, planeIndex: 0)
        try self.init(destination: &texture, orthoType: orthoType, loadAction: loadAction)
    }

    public convenience init(pixelBuffer: inout CVPixelBuffer, orthoType: OrthoType, renderSize: CGSize, loadAction: MTLLoadAction = MTLLoadAction.load) throws {
        var texture: MCTexture = try MCTexture(pixelBuffer: pixelBuffer, planeIndex: 0)
        try self.init(destination: &texture, orthoType: orthoType, loadAction: loadAction)
    }
}

extension MCCanvas {
    public func update(destination: inout MCTexture, orthoType: OrthoType, loadAction: MTLLoadAction) throws {
        let renderSize: MCSize = MCSize(w: destination.size.w, h: destination.size.h)

        self.drawInfo.renderPassDescriptor.colorAttachments[0].loadAction = loadAction
        self.drawInfo.renderPassDescriptor.colorAttachments[0].texture = destination.texture

        self.drawInfo.orthoType = orthoType
        self.projection.glkMatrix = orthoType.getMatrix(size: self.drawInfo.renderSize.toCGSize())
        self.drawInfo.projectionMatrixBuffer = try MCCore.makeBuffer(data: self.projection.raw)
        self.drawInfo.renderSize = renderSize
    }

    public func update(destination: inout MCTexture) throws {
        self.drawInfo.renderPassDescriptor.colorAttachments[0].texture = destination.texture
    }
}

extension MCCanvas {
    public func draw(commandBuffer: MTLCommandBuffer, objects: [MCPrimitiveTypeProtocol]) throws {
        for object in objects {
            try object.draw(commandBuffer: commandBuffer, drawInfo: self.drawInfo)
        }
    }
}

extension MCCanvas {
    public func fill(commandBuffer: MTLCommandBuffer, color: MCColor) throws {
        let object: MCPrimitiveTypeProtocol
        switch self.drawInfo.orthoType {
        case .perspective:
            object = try MCPrimitive.Rectangle(
                position: SIMD2<Float>(x: -1.0, y: -1.0),
                w: 2.0,
                h: 2.0,
                color: color
            )
        case .center:
            object = try MCPrimitive.Rectangle(
                position: SIMD2<Float>(x: -Float(self.drawInfo.renderSize.w / 2.0), y: -Float(self.drawInfo.renderSize.h / 2.0)),
                w: Float(self.drawInfo.renderSize.w),
                h: Float(self.drawInfo.renderSize.h),
                color: color
            )
        case .topLeft, .bottomLeft:
            object = try MCPrimitive.Rectangle(
                position: SIMD2<Float>(x: 0.0, y: 0.0),
                w: Float(self.drawInfo.renderSize.w),
                h: Float(self.drawInfo.renderSize.h),
                color: color
            )
        }
        try object.draw(commandBuffer: commandBuffer, drawInfo: self.drawInfo)
    }
}

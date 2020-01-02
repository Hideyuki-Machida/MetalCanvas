//
//  MCCanvas.swift
//  CameraCore
//
//  Created by hideyuki machida on 2018/12/23.
//  Copyright © 2018 hideyuki machida. All rights reserved.
//

import Foundation
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

        func getMatrix(size: MCSize) -> GLKMatrix4 {
            switch self {
            case .perspective: return MCGeom.Matrix4x4().glkMatrix
            case .center: return GLKMatrix4MakeOrtho(-(size.x / 2), (size.x / 2), (size.y / 2), -(size.y / 2), -1, 1)
            case .topLeft: return GLKMatrix4MakeOrtho(0, (size.x), (size.y), 0, -1, 1)
            case .bottomLeft: return GLKMatrix4MakeOrtho(0, (size.x), 0, (size.y), -1, 1)
            }
        }
    }

    private var projection: MCGeom.Matrix4x4 = MCGeom.Matrix4x4()
    public private(set) var drawInfo: MCPrimitive.DrawInfo
    public var texture: MTLTexture? {
        return drawInfo.renderPassDescriptor.colorAttachments[0].texture
    }

    public init(destination: inout MCTexture, orthoType: OrthoType, loadAction: MTLLoadAction = MTLLoadAction.load) throws {
        let renderSize: MCSize = destination.size
        self.projection.glkMatrix = orthoType.getMatrix(size: renderSize)

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

    public convenience init(orthoType: OrthoType, renderSize: MCSize, loadAction: MTLLoadAction = MTLLoadAction.load) throws {
        guard var pixelBuffer: CVPixelBuffer = CVPixelBuffer.create(size: renderSize) else { throw ErrorType.setupError }
        var texture: MCTexture = try MCTexture(pixelBuffer: &pixelBuffer, planeIndex: 0)
        try self.init(destination: &texture, orthoType: orthoType, loadAction: loadAction)
    }

    public convenience init(pixelBuffer: inout CVPixelBuffer, orthoType: OrthoType, renderSize: MCSize, loadAction: MTLLoadAction = MTLLoadAction.load) throws {
        var texture: MCTexture = try MCTexture(pixelBuffer: &pixelBuffer, planeIndex: 0)
        try self.init(destination: &texture, orthoType: orthoType, loadAction: loadAction)
    }
}

extension MCCanvas {
    public func update(destination: inout MCTexture, orthoType: OrthoType, loadAction: MTLLoadAction) throws {
        let renderSize: MCSize = destination.size

        self.drawInfo.renderPassDescriptor.colorAttachments[0].loadAction = loadAction
        self.drawInfo.renderPassDescriptor.colorAttachments[0].texture = destination.texture

        self.drawInfo.orthoType = orthoType
        self.projection.glkMatrix = orthoType.getMatrix(size: self.drawInfo.renderSize)
        self.drawInfo.projectionMatrixBuffer = try MCCore.makeBuffer(data: self.projection.raw)
        self.drawInfo.renderSize = renderSize
    }

    public func update(destination: inout MCTexture) throws {
        self.drawInfo.renderPassDescriptor.colorAttachments[0].texture = destination.texture
    }
}

extension MCCanvas {
    public func draw(commandBuffer: inout MTLCommandBuffer, objects: [MCPrimitiveTypeProtocol]) throws {
        for object in objects {
            try object.draw(commandBuffer: &commandBuffer, drawInfo: self.drawInfo)
        }
    }
}

extension MCCanvas {
    public func fill(commandBuffer: inout MTLCommandBuffer, color: MCColor) throws {
        let object: MCPrimitiveTypeProtocol
        switch self.drawInfo.orthoType {
        case .perspective:
            object = try MCPrimitive.Rectangle(
                position: MCPoint(x: -1.0, y: -1.0),
                w: 2.0,
                h: 2.0,
                color: color
            )
        case .center:
            object = try MCPrimitive.Rectangle(
                position: MCPoint(x: -(self.drawInfo.renderSize.x / 2.0), y: -(self.drawInfo.renderSize.y / 2.0)),
                w: self.drawInfo.renderSize.x,
                h: self.drawInfo.renderSize.y,
                color: color
            )
        case .topLeft, .bottomLeft:
            object = try MCPrimitive.Rectangle(
                position: MCPoint(x: 0.0, y: 0.0),
                w: self.drawInfo.renderSize.x,
                h: self.drawInfo.renderSize.y,
                color: color
            )
        }
        try object.draw(commandBuffer: &commandBuffer, drawInfo: self.drawInfo)
    }
}

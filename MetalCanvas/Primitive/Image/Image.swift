//
//  Image.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/03.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation

extension MCPrimitive {
    public struct Image: MCPrimitiveTypeProtocol {
        fileprivate let pipelineState: MCPipelineState
        fileprivate let vertexInBuffer: MTLBuffer

        public var texture: MCTexture
        var imageMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4.init()
        var posMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4.init()
        var objMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4.init()
        let objMatBuffer: MTLBuffer

        public init(texture: MCTexture, ppsition: SIMD3<Float>, transform: MCGeom.Matrix4x4 = MCGeom.Matrix4x4(), anchorPoint: MCPrimitive.anchor = .topLeft) throws {
            
            self.pipelineState = try MCPipelineState.init(
                vertex: MCFunction.Primitive.image.vertex,
                fragment: MCFunction.Primitive.image.fragment,
                label: "MCPrimitive Image"
            )

            self.texture = texture
            self.vertexInBuffer = try MCCore.makeBuffer(data: MCShaderPreset.normalizedVertex)

            self.imageMat.scale(x: Float(texture.width) / 2.0, y: (Float(texture.height) / 2.0) * -1, z: 0.0)

            switch anchorPoint {
                case .topLeft: self.imageMat.translate(x: 1, y: -1, z: 0.0)
                case .bottomLeft: self.imageMat.translate(x: 1, y: 1, z: 0.0)
                case .center: self.imageMat.translate(x: 0, y: 0, z: 0.0)
            }
            
            self.posMat.translate(x: ppsition.x, y: ppsition.y, z: 0.0)
            self.objMat = self.posMat * (transform * self.imageMat)
            self.objMatBuffer = try MCCore.makeBuffer(data: self.objMat.raw())
        }

        public func draw(commandBuffer: inout MTLCommandBuffer, drawInfo: MCPrimitive.DrawInfo) throws {
            guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: drawInfo.renderPassDescriptor) else { throw MCPrimitive.ErrorType.drawError }
            renderCommandEncoder.setRenderPipelineState(self.pipelineState.renderPipelineState)
            renderCommandEncoder.setVertexBuffer(self.vertexInBuffer, offset: 0, index: Int(MCVertexIndex.rawValue))
            renderCommandEncoder.setVertexBuffer(drawInfo.projectionMatrixBuffer, offset: 0, index: Int(MCProjectionMatrixIndex.rawValue))
            renderCommandEncoder.setVertexBuffer(self.objMatBuffer, offset: 0, index: 30)
            renderCommandEncoder.setFragmentTexture(self.texture.texture, index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            renderCommandEncoder.endEncoding()
        }
    }
}

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
        // MARK: - vars

        private let pipelineState: MCPipelineState
        private let vertexInBuffer: MTLBuffer

        private var texture: MCTexture
        private let imageMat: MCGeom.Matrix4x4
        private let posMat: MCGeom.Matrix4x4
        private let objMat: MCGeom.Matrix4x4
        private let objMatBuffer: MTLBuffer

        // MARK: - func

        public init(texture: MCTexture, position: SIMD3<Float>, transform: MCGeom.Matrix4x4 = MCGeom.Matrix4x4(), anchorPoint: MCPrimitive.Anchor = .topLeft) throws {
            self.pipelineState = try MCPipelineState(
                vertex: MCPrimitive.Image.shaderFunc.vertex,
                fragment: MCPrimitive.Image.shaderFunc.fragment,
                label: "MCPrimitive Image"
            )

            self.texture = texture
            self.vertexInBuffer = try MCCore.makeBuffer(data: MCShaderPreset.normalizedVertex)

            // imageMatrix4x4
            var imageMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4()
            imageMat.scale(x: Float(texture.width) / 2.0, y: (Float(texture.height) / 2.0) * -1, z: 0.0)

            switch anchorPoint {
            case .topLeft: imageMat.translate(x: 1, y: -1, z: 0.0)
            case .bottomLeft: imageMat.translate(x: 1, y: 1, z: 0.0)
            case .center: imageMat.translate(x: 0, y: 0, z: 0.0)
            }

            self.imageMat = imageMat

            // positionMatrix4x4
            var posMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4()
            posMat.translate(x: position.x, y: position.y, z: 0.0)
            self.posMat = posMat

            // objectMatrix4x4
            self.objMat = self.posMat * (transform * self.imageMat)

            // objMatrix4x4MTLBuffer
            self.objMatBuffer = try MCCore.makeBuffer(data: self.objMat.raw)
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

extension MCPrimitive.Image {
    // MARK: - MTLFunction

    private static let shaderFunc: ShaderFunc = MCPrimitive.Image.ShaderFunc()

    fileprivate struct ShaderFunc {
        fileprivate let vertex: MTLFunction = MCCore.library.makeFunction(name: "vertex_primitive_image")!
        fileprivate let fragment: MTLFunction = MCCore.library.makeFunction(name: "fragment_primitive_image")!
    }
}

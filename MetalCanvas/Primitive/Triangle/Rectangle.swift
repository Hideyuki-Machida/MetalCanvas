//
//  Rectangle.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/05/15.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation

extension MCPrimitive {
    public struct Rectangle: MCPrimitiveTypeProtocol {
        // MARK: - vars

        fileprivate let pipelineState: MCPipelineState
        fileprivate let vertexInBuffer: MTLBuffer

        // MARK: - func

        public init(position: SIMD2<Float>, w: Float, h: Float, color: MCColor) throws {
            let vertex: [MCPrimitiveVertexIn] = [
                MCPrimitiveVertexIn(position: SIMD4<Float>(x: position.x, y: position.y, z: 0.0, w: 1.0), color: color.color), // LT
                MCPrimitiveVertexIn(position: SIMD4<Float>(x: position.x, y: position.y + h, z: 0.0, w: 1.0), color: color.color), // LB
                MCPrimitiveVertexIn(position: SIMD4<Float>(x: position.x + w, y: position.y, z: 0.0, w: 1.0), color: color.color), // RT
                MCPrimitiveVertexIn(position: SIMD4<Float>(x: position.x + w, y: position.y + h, z: 0.0, w: 1.0), color: color.color), // RB
            ]

            self.pipelineState = try MCPipelineState(
                vertex: MCPrimitive.Rectangle.shaderFunc.vertex,
                fragment: MCPrimitive.Rectangle.shaderFunc.fragment,
                label: "MCPrimitive Rectangle"
            )

            self.vertexInBuffer = try MCCore.makeBuffer(data: vertex)
        }

        public func draw(commandBuffer: inout MTLCommandBuffer, drawInfo: MCPrimitive.DrawInfo) throws {
            guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: drawInfo.renderPassDescriptor) else { throw MCPrimitive.ErrorType.drawError }
            renderCommandEncoder.setRenderPipelineState(self.pipelineState.renderPipelineState)
            renderCommandEncoder.setVertexBuffer(self.vertexInBuffer, offset: 0, index: Int(MCVertexIndex.rawValue))
            renderCommandEncoder.setVertexBuffer(drawInfo.projectionMatrixBuffer, offset: 0, index: Int(MCProjectionMatrixIndex.rawValue))
            renderCommandEncoder.drawPrimitives(type: MTLPrimitiveType.triangleStrip, vertexStart: 0, vertexCount: 4)
            renderCommandEncoder.endEncoding()
        }
    }
}

extension MCPrimitive.Rectangle {
    // MARK: - MTLFunction

    private static let shaderFunc: ShaderFunc = MCPrimitive.Rectangle.ShaderFunc()

    fileprivate struct ShaderFunc {
        fileprivate let vertex: MTLFunction = MCCore.library.makeFunction(name: "vertex_primitive_triangle")!
        fileprivate let fragment: MTLFunction = MCCore.library.makeFunction(name: "fragment_primitive_triangle")!
    }
}

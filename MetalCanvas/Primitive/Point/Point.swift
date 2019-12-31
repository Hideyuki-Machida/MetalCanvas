//
//  Point.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2018/12/25.
//  Copyright © 2018 Donuts. All rights reserved.
//

import Foundation

extension MCPrimitive {
    public struct Point: MCPrimitiveTypeProtocol {
        // MARK: - vars

        fileprivate let pipelineState: MCPipelineState
        fileprivate let pointIn: MCPointIn

        // MARK: - func

        public init(position: SIMD3<Float>, color: MCColor, size: Float) throws {
            self.pipelineState = try MCPipelineState(
                vertex: MCPrimitive.Point.shaderFunc.vertex,
                fragment: MCPrimitive.Point.shaderFunc.fragment,
                label: "MCPrimitive Point"
            )

            self.pointIn = MCPointIn(position: position,
                                     color: SIMD4<Float>(color.color[0], color.color[1], color.color[2], color.color[3]),
                                     size: size)
        }

        public func draw(commandBuffer: inout MTLCommandBuffer, drawInfo: MCPrimitive.DrawInfo) throws {
            guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: drawInfo.renderPassDescriptor) else { throw ErrorType.drawError }
            renderCommandEncoder.setRenderPipelineState(self.pipelineState.renderPipelineState)
            renderCommandEncoder.setVertexBytes([self.pointIn], length: MemoryLayout<MCPointIn>.size, index: Int(MCVertexIndex.rawValue))
            renderCommandEncoder.setVertexBuffer(drawInfo.projectionMatrixBuffer, offset: 0, index: Int(MCProjectionMatrixIndex.rawValue))
            renderCommandEncoder.drawPrimitives(type: MTLPrimitiveType.point, vertexStart: 0, vertexCount: 1)
            renderCommandEncoder.endEncoding()
        }
    }
}

extension MCPrimitive.Point {
    // MARK: - MTLFunction

    private static let shaderFunc: ShaderFunc = MCPrimitive.Point.ShaderFunc()

    fileprivate struct ShaderFunc {
        fileprivate let vertex: MTLFunction = MCCore.library.makeFunction(name: "vertex_primitive_point")!
        fileprivate let fragment: MTLFunction = MCCore.library.makeFunction(name: "fragment_primitive_point")!
    }
}

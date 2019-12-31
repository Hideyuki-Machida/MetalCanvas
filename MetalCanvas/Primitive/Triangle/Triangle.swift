//
//  Triangle.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/05/15.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation

extension MCPrimitive {
    public struct Triangle: MCPrimitiveTypeProtocol {
        // MARK: - vars

        fileprivate let pipelineState: MCPipelineState
        fileprivate let vertexInBuffer: MTLBuffer
        fileprivate let vertexCount: Int

        // MARK: - func

        public init(positions: [SIMD2<Float>], color: MCColor) throws {
            var data: [SIMD4<Float>] = []
            for pos in positions {
                data.append(SIMD4<Float>(x: pos.x, y: pos.y, z: 0.0, w: 1.0))
            }

            self.pipelineState = try MCPipelineState(
                vertex: MCPrimitive.Triangle.shaderFunc.vertex,
                fragment: MCPrimitive.Triangle.shaderFunc.fragment,
                label: "MCPrimitive Triangle"
            )

            self.vertexInBuffer = try MCCore.makeBuffer(data: data)
            self.vertexCount = data.count
        }

        public func draw(commandBuffer: inout MTLCommandBuffer, drawInfo: MCPrimitive.DrawInfo) throws {
            guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: drawInfo.renderPassDescriptor) else { throw MCPrimitive.ErrorType.drawError }
            renderCommandEncoder.setRenderPipelineState(self.pipelineState.renderPipelineState)
            renderCommandEncoder.setVertexBuffer(self.vertexInBuffer, offset: 0, index: Int(MCVertexIndex.rawValue))
            renderCommandEncoder.setVertexBuffer(drawInfo.projectionMatrixBuffer, offset: 0, index: Int(MCProjectionMatrixIndex.rawValue))
            renderCommandEncoder.drawPrimitives(type: MTLPrimitiveType.triangleStrip, vertexStart: 0, vertexCount: self.vertexCount)
            renderCommandEncoder.endEncoding()
        }
    }
}

extension MCPrimitive.Triangle {
    // MARK: - MTLFunction

    private static let shaderFunc: ShaderFunc = MCPrimitive.Triangle.ShaderFunc()

    fileprivate struct ShaderFunc {
        fileprivate let vertex: MTLFunction = MCCore.library.makeFunction(name: "vertex_primitive_triangle")!
        fileprivate let fragment: MTLFunction = MCCore.library.makeFunction(name: "fragment_primitive_triangle")!
    }
}

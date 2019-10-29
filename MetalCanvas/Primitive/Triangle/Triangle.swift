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
        fileprivate let pipelineState: MCPipelineState
        fileprivate let vertexInBuffer: MTLBuffer
        fileprivate let vertexCount: Int
        
        public init(positions: [SIMD2<Float>], color: MCColor) throws {
            var ps: [SIMD4<Float>] = []
            for p in positions {
                ps.append(SIMD4<Float>.init(x: p.x, y: p.y, z: 0.0, w: 1.0))
            }
            self.pipelineState = try MCPipelineState.init(
                vertex: MCFunction.Primitive.triangle.vertex,
                fragment: MCFunction.Primitive.triangle.fragment,
                label: "MCPrimitive Triangle"
            )

            self.vertexInBuffer = try MCCore.makeBuffer(data: ps)
            self.vertexCount = ps.count
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

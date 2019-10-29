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
        fileprivate let pipelineState: MCPipelineState
        fileprivate let vertexInBuffer: MTLBuffer

        public init(position: SIMD2<Float>, w: Float, h: Float, color: MCColor) throws {
            let vertex: [MCPrimmitiveVertexIn] = [
                MCPrimmitiveVertexIn.init(position: SIMD4<Float>.init(x: position.x, y: position.y, z: 0.0, w: 1.0), color: color.color), //LT
                MCPrimmitiveVertexIn.init(position: SIMD4<Float>.init(x: position.x, y: position.y + h, z: 0.0, w: 1.0), color: color.color), //LB
                MCPrimmitiveVertexIn.init(position: SIMD4<Float>.init(x: position.x + w, y: position.y, z: 0.0, w: 1.0), color: color.color), //RT
                MCPrimmitiveVertexIn.init(position: SIMD4<Float>.init(x: position.x + w, y: position.y + h, z: 0.0, w: 1.0), color: color.color) //RB
            ]

            self.pipelineState = try MCPipelineState.init(
                vertex: MCFunction.Primitive.triangle.vertex,
                fragment: MCFunction.Primitive.triangle.fragment,
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

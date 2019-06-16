//
//  Rectangle.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/05/15.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation

#if targetEnvironment(simulator)
extension MCPrimitive {}
#else
extension MCPrimitive {
	public struct Rectangle: MCPrimitiveTypeProtocol {
		fileprivate var renderPipelineState: MTLRenderPipelineState
		
		public enum ErrorType: Error {
			case setupError
			case drawError
			case endError
		}
		
		fileprivate var vertex: [Float]
		fileprivate var color: [Float]
		
		public init(position: MCGeom.Vec2D, w: Float, h: Float, color: MCColor) throws {
			var vertex: [Float] = []

			//LT
			vertex.append(position.x)
			vertex.append(position.y)
			vertex.append(0.0)

			//LB
			vertex.append(position.x)
			vertex.append(position.y + h)
			vertex.append(0.0)

			//RT
			vertex.append(position.x + w)
			vertex.append(position.y)
			vertex.append(0.0)

			//RB
			vertex.append(position.x + w)
			vertex.append(position.y + h)
			vertex.append(0.0)

			let vertexFunction: MTLFunction = MCFunction.Primitive.triangle.vertex
			let fragmentFunction: MTLFunction = MCFunction.Primitive.triangle.fragment
			
			let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
			renderPipelineDescriptor.vertexFunction = vertexFunction
			renderPipelineDescriptor.fragmentFunction = fragmentFunction
			renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
			
			self.renderPipelineState = try MCCore.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
			
			self.vertex = vertex
			self.color = color.color
		}
		
		public func draw(commandBuffer: inout MTLCommandBuffer, drawInfo: MCPrimitive.DrawInfo) throws {
			let vertexBuffer: MTLBuffer = try MCCore.makeBuffer(data: self.vertex)
			let colorBuffer: MTLBuffer = try MCCore.makeBuffer(data: self.color)
			
			guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: drawInfo.renderPassDescriptor) else { throw ErrorType.drawError }
			renderCommandEncoder.setRenderPipelineState(self.renderPipelineState)
			renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: Int(MCVertexIndex.rawValue))
			renderCommandEncoder.setVertexBuffer(colorBuffer, offset: 0, index: Int(MCColorIndex.rawValue))
			renderCommandEncoder.setVertexBuffer(drawInfo.projectionMatrixBuffer, offset: 0, index: Int(MCProjectionMatrixIndex.rawValue))
			renderCommandEncoder.drawPrimitives(type: MTLPrimitiveType.triangleStrip, vertexStart: 0, vertexCount: self.vertex.count / 3)
			renderCommandEncoder.endEncoding()
		}
	}
}
#endif

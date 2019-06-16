//
//  MCPoints.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/03.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation

#if targetEnvironment(simulator)
extension MCPrimitive {}
#else
extension MCPrimitive {
	public struct Points: MCPrimitiveTypeProtocol {
		fileprivate var renderPipelineState: MTLRenderPipelineState
		
		public enum ErrorType: Error {
			case setupError
			case drawError
			case endError
		}
		
		fileprivate var vertex: [Float]
		fileprivate var color: [Float]
		fileprivate var size: [Float]
		
		public init(positions: [MCGeom.Vec3D], color: MCColor, size: Float) throws {
			var vertex: [Float] = []
			for p in positions { vertex.append(p.x); vertex.append(p.y); vertex.append(p.z) }
			try self.init(positions: vertex, color: color, size: size)
		}
		
		public init(positions: [vector_float3], color: MCColor, size: Float) throws {
			var vertex: [Float] = []
			for p in positions { vertex.append(p.x); vertex.append(p.y); vertex.append(p.z) }
			try self.init(positions: vertex, color: color, size: size)
		}
		
		public init(positions: [Float], color: MCColor, size: Float) throws {
			let vertexFunction: MTLFunction = MCFunction.Primitive.points.vertex
			let fragmentFunction: MTLFunction = MCFunction.Primitive.points.fragment
			
			let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
			renderPipelineDescriptor.vertexFunction = vertexFunction
			renderPipelineDescriptor.fragmentFunction = fragmentFunction
			renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
			self.renderPipelineState = try MCCore.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
			
			self.vertex = positions
			self.color = color.color
			self.size = [size]
		}
		
		public func draw(commandBuffer: inout MTLCommandBuffer, drawInfo: MCPrimitive.DrawInfo) throws {
			let vertexBuffer: MTLBuffer = try MCCore.makeBuffer(data: self.vertex)
			let colorBuffer: MTLBuffer = try MCCore.makeBuffer(data: self.color)
			let sizeBuffer: MTLBuffer = try MCCore.makeBuffer(data: self.size)
			//print(commandBuffer)
			//print(drawInfo.renderPassDescriptor)
			guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: drawInfo.renderPassDescriptor) else { throw ErrorType.drawError }
			renderCommandEncoder.setRenderPipelineState(self.renderPipelineState)
			renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: Int(MCVertexIndex.rawValue))
			renderCommandEncoder.setVertexBuffer(colorBuffer, offset: 0, index: Int(MCColorIndex.rawValue))
			renderCommandEncoder.setVertexBuffer(sizeBuffer, offset: 0, index: Int(MCSizeIndex.rawValue))
			renderCommandEncoder.setVertexBuffer(drawInfo.projectionMatrixBuffer, offset: 0, index: Int(MCProjectionMatrixIndex.rawValue))
			renderCommandEncoder.drawPrimitives(type: MTLPrimitiveType.point, vertexStart: 0, vertexCount: self.vertex.count / 3)
			renderCommandEncoder.endEncoding()
		}
	}
}
#endif

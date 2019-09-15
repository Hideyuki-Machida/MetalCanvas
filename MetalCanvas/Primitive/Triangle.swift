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
		fileprivate var renderPipelineState: MTLRenderPipelineState
		
		public enum ErrorType: Error {
			case setupError
			case drawError
			case endError
		}
		
		fileprivate var vertex: [Float]
		fileprivate var color: [Float]
		
		public init(positions: [MCGeom.Vec3D], color: MCColor) throws {
			var vertex: [Float] = []
			for p in positions { vertex.append(p.x); vertex.append(p.y); vertex.append(p.z) }
			try self.init(positions: vertex, color: color)
		}
		
		public init(positions: [vector_float3], color: MCColor, size: Float) throws {
			var vertex: [Float] = []
			for p in positions { vertex.append(p.x); vertex.append(p.y); vertex.append(p.z) }
			try self.init(positions: vertex, color: color)
		}
		
		public init(positions: [Float], color: MCColor) throws {
			let vertexFunction: MTLFunction = MCFunction.Primitive.points.vertex
			let fragmentFunction: MTLFunction = MCFunction.Primitive.points.fragment
			
			let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
			renderPipelineDescriptor.vertexFunction = vertexFunction
			renderPipelineDescriptor.fragmentFunction = fragmentFunction
			renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
			renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
			
			renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
			renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
			renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
			renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
			renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
			renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

			self.renderPipelineState = try MCCore.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
			
			self.vertex = positions
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
			renderCommandEncoder.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: self.vertex.count / 3)
			renderCommandEncoder.endEncoding()
		}
	}
}

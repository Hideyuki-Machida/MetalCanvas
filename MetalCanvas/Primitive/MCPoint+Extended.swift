//
//  MTLCPoint+Extended.swift
//  iOS_AVModule
//
//  Created by hideyuki machida on 2018/12/25.
//  Copyright © 2018 町田 秀行. All rights reserved.
//

import Foundation

extension MCPoint: MCPrimitiveTypeProtocol {
	fileprivate var renderPipelineState: MTLRenderPipelineState {
		let vertexFunction: MTLFunction = MCFunction.Primitive.point.vertex
		let fragmentFunction: MTLFunction = MCFunction.Primitive.point.fragment
		
		let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
		renderPipelineDescriptor.vertexFunction = vertexFunction
		renderPipelineDescriptor.fragmentFunction = fragmentFunction
		renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
		return try! MCCore.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
	}
	
	public enum ErrorType: Error {
		case setupError
		case drawError
		case endError
	}

	public init(ppsition: MCGeom.Vec3D, color: MCColor, size: Float) {
		self.init()
		self.position = [ppsition.x, ppsition.y, ppsition.z]
		let color: [Float] = color.color
		self.color = [color[0], color[1], color[2], color[3]]
		self.size = size
	}
	public init(ppsition: vector_float3, color: MCColor, size: Float) {
		self.init()
		self.position = ppsition
		let color: [Float] = color.color
		self.color = [color[0], color[1], color[2], color[3]]
		self.size = size
	}
	
	public func draw(commandBuffer: inout MTLCommandBuffer, drawInfo: MCPrimitive.DrawInfo) throws {
		guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: drawInfo.renderPassDescriptor) else { throw ErrorType.drawError }
		renderCommandEncoder.setRenderPipelineState(self.renderPipelineState)
		renderCommandEncoder.setRenderPipelineState(renderPipelineState)
		renderCommandEncoder.setVertexBytes([self], length: MemoryLayout<MCPoint>.size, index: Int(MCVertexIndex.rawValue))
		renderCommandEncoder.setVertexBuffer(drawInfo.projectionMatrixBuffer, offset: 0, index: Int(MCProjectionMatrixIndex.rawValue))
		renderCommandEncoder.drawPrimitives(type: MTLPrimitiveType.point, vertexStart: 0, vertexCount: 1)
		renderCommandEncoder.endEncoding()
	}

}

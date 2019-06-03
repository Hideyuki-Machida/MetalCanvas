//
//  Image.swift
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
	public struct Image: MCPrimitiveTypeProtocol {
		fileprivate let vertexData: [Float] = [-1, -1, 0, 1,
											   1, -1, 0, 1,
											   -1,  1, 0, 1,
											   1,  1, 0, 1]
		
		fileprivate let textureCoordinateData: [Float] = [0, 1,
														  1, 1,
														  0, 0,
														  1, 0]

		fileprivate var renderPipelineState: MTLRenderPipelineState
		
		public var texture: MCTexture
		var imageMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4.init()
		var posMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4.init()
		var objMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4.init()
		let vertexBuffer: MTLBuffer
		let texCoordBuffer: MTLBuffer
		let objMatBuffer: MTLBuffer
		
		public init(texture: MCTexture, ppsition: MCGeom.Vec3D, transform: MCGeom.Matrix4x4 = MCGeom.Matrix4x4(), anchorPoint: MCPrimitive.anchor = .topLeft) throws {
			let vertexFunction: MTLFunction = MCFunction.Primitive.image.vertex
			let fragmentFunction: MTLFunction = MCFunction.Primitive.image.fragment
			
			let renderPipelineDescriptor: MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
			renderPipelineDescriptor.vertexFunction = vertexFunction
			renderPipelineDescriptor.fragmentFunction = fragmentFunction
			//renderPipelineDescriptor.isAlphaToOneEnabled = true

			renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
			/*
			renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true

			renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
			renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
			renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
			renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
			renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
			renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
			*/
			self.renderPipelineState = try MCCore.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
			
			self.texture = texture
			self.vertexBuffer = try MCCore.makeBuffer(data: self.vertexData)
			self.texCoordBuffer = try MCCore.makeBuffer(data: self.textureCoordinateData)
			
			self.imageMat.scale(x: Float(texture.width) / 2.0, y: (Float(texture.height) / 2.0) * -1, z: 0.0)

			switch anchorPoint {
				case .topLeft: self.imageMat.translate(x: 1, y: -1, z: 0.0)
				case .bottomLeft: self.imageMat.translate(x: 1, y: 1, z: 0.0)
				case .center: self.imageMat.translate(x: 0, y: 0, z: 0.0)
			}
			
			self.posMat.translate(x: ppsition.x, y: ppsition.y, z: 0.0)
			
			self.objMat = self.posMat * (transform * self.imageMat)
			self.objMatBuffer = try MCCore.makeBuffer(data: self.objMat.raw())
		}
		
		public func draw(commandBuffer: inout MTLCommandBuffer, drawInfo: MCPrimitive.DrawInfo) throws {
			guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: drawInfo.renderPassDescriptor) else { throw MCPrimitive.ErrorType.drawError }
			renderCommandEncoder.setRenderPipelineState(self.renderPipelineState)
			renderCommandEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: Int(MCVertexIndex.rawValue))
			renderCommandEncoder.setVertexBuffer(self.texCoordBuffer, offset: 0, index: Int(MCTexCoord.rawValue))
			renderCommandEncoder.setVertexBuffer(drawInfo.projectionMatrixBuffer, offset: 0, index: Int(MCProjectionMatrixIndex.rawValue))
			renderCommandEncoder.setVertexBuffer(self.objMatBuffer, offset: 0, index: 30)
			renderCommandEncoder.setFragmentTexture(self.texture.texture, index: 0)
			renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
			renderCommandEncoder.endEncoding()
		}
	}
}
#endif

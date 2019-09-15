//
//  MCFilterYCbCrToRGB.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/03.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation

extension MCFilter.ColorSpace {
	public struct YCbCrToRGB {

		fileprivate let vertexData: [Float] = [-1, -1, 0, 1,
											   1, -1, 0, 1,
											   -1,  1, 0, 1,
											   1,  1, 0, 1]
		
		fileprivate let textureCoordinateData: [Float] = [0, 1,
														  1, 1,
														  0, 0,
														  1, 0]
		
		private var renderPipelineState: MTLRenderPipelineState!
		private var threadsPerThreadgroup: MTLSize
		
		public init () {
			self.threadsPerThreadgroup = MTLSize(width: 8, height: 1, depth: 1)
			let vertexFunction: MTLFunction = MCFunction.ColorSpace.YCbCrToRGB.vertex
			let fragmentFunction: MTLFunction = MCFunction.ColorSpace.YCbCrToRGB.fragment

			let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
			renderPipelineDescriptor.vertexFunction = vertexFunction
			renderPipelineDescriptor.fragmentFunction = fragmentFunction
			renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
			self.renderPipelineState = try! MCCore.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
		}
		
		public func processing(commandBuffer: inout MTLCommandBuffer, capturedImageTextureY: inout MCTexture, capturedImageTextureCbCr: inout MCTexture, renderPassDescriptor: MTLRenderPassDescriptor, renderSize: CGSize) throws {

			let vertexBuffer: MTLBuffer = try MCCore.makeBuffer(data: self.vertexData)
			let texCoordBuffer: MTLBuffer = try MCCore.makeBuffer(data: self.textureCoordinateData)
			guard let renderCommandEncoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { throw MCFilter.ErrorType.drawError }
			renderCommandEncoder.setRenderPipelineState(self.renderPipelineState)
			renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: Int(MCVertexIndex.rawValue))
			renderCommandEncoder.setVertexBuffer(texCoordBuffer, offset: 0, index: Int(MCTexCoord.rawValue))
			renderCommandEncoder.setFragmentTexture(capturedImageTextureY.texture, index: 0)
			renderCommandEncoder.setFragmentTexture(capturedImageTextureCbCr.texture, index: 1)
			renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
			renderCommandEncoder.endEncoding()
		}
	}
}

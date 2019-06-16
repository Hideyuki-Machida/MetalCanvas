//
//  LutFilter.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/02/24.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation

#if targetEnvironment(simulator)
extension MCFilter.ColorProcessing {}
#else
extension MCFilter.ColorProcessing {
	public struct Lut3DFilter {
		fileprivate let vertexData: [Float] = [-1, -1, 0, 1,
											   1, -1, 0, 1,
											   -1,  1, 0, 1,
											   1,  1, 0, 1]
		
		fileprivate let textureCoordinateData: [Float] = [0, 1,
														  1, 1,
														  0, 0,
														  1, 0]
		
		fileprivate var renderPassDescriptor: MTLRenderPassDescriptor = MTLRenderPassDescriptor()
		private var renderPipelineState: MTLRenderPipelineState!
		private var threadsPerThreadgroup: MTLSize
		
		public init () {
			self.renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
			self.renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)

			self.threadsPerThreadgroup = MTLSize(width: 8, height: 1, depth: 1)
			let vertexFunction: MTLFunction = MCFunction.ColorProcessing.lut3D.vertex
			let fragmentFunction: MTLFunction = MCFunction.ColorProcessing.lut3D.fragment
			
			let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
			renderPipelineDescriptor.vertexFunction = vertexFunction
			renderPipelineDescriptor.fragmentFunction = fragmentFunction
			renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
			self.renderPipelineState = try! MCCore.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
		}
		
		public func processing(commandBuffer: inout MTLCommandBuffer, imageTexture: MCTexture, lutImageTexture: MCTexture, destinationTexture: inout MCTexture) throws {
			self.renderPassDescriptor.colorAttachments[0].texture = destinationTexture.texture
			
			let vertexBuffer: MTLBuffer = try MCCore.makeBuffer(data: self.vertexData)
			let texCoordBuffer: MTLBuffer = try MCCore.makeBuffer(data: self.textureCoordinateData)
			guard let renderCommandEncoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { throw MCFilter.ErrorType.drawError }
			renderCommandEncoder.setRenderPipelineState(self.renderPipelineState)
			renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: Int(MCVertexIndex.rawValue))
			renderCommandEncoder.setVertexBuffer(texCoordBuffer, offset: 0, index: Int(MCTexCoord.rawValue))
			renderCommandEncoder.setFragmentTexture(imageTexture.texture, index: 0)
			renderCommandEncoder.setFragmentTexture(lutImageTexture.texture, index: 1)
			renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
			renderCommandEncoder.endEncoding()
		}

	}
}
#endif

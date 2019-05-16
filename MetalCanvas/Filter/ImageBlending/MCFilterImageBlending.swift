//
//  MCFilterImageBlending.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/02.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation

extension MCFilter {
	public struct ImageBlending {
		private var pipeline: MTLComputePipelineState
		private var threadsPerThreadgroup: MTLSize
		
		public init (mode: MCFunction.ImageBlending) throws {
			self.threadsPerThreadgroup = MTLSize(width: 16, height: 1, depth: 1)
			let function: MTLFunction = mode.kernel
			self.pipeline = try MCCore.device.makeComputePipelineState(function: function)
		}
		
		public func processing(commandBuffer: inout MTLCommandBuffer, originalTexture: inout MCTexture, overTexture: inout MCTexture, destinationTexture: inout MCTexture, renderSize: CGSize) throws {
			let threadsPerGrid: MTLSize = MTLSize(width: destinationTexture.width, height: destinationTexture.height, depth: 1)
			
			let encoder: MTLComputeCommandEncoder = commandBuffer.makeComputeCommandEncoder()!
			encoder.setComputePipelineState(self.pipeline)
			encoder.setTexture(originalTexture.texture, index: Int(OriginalTextureIndex.rawValue))
			encoder.setTexture(overTexture.texture, index: Int(OverTextureIndex.rawValue))
			encoder.setTexture(destinationTexture.texture, index: Int(DestinationTextureIndex.rawValue))
			encoder.dispatchThreadgroups(threadsPerGrid, threadsPerThreadgroup: self.threadsPerThreadgroup)
			encoder.endEncoding()
		}
	}
}

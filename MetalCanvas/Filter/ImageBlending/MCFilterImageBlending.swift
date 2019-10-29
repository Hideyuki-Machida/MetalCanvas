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
        
        public init (mode: MCFunction.ImageBlending) throws {
            let function: MTLFunction = mode.kernel
            self.pipeline = try MCCore.device.makeComputePipelineState(function: function)
        }
        
        public func process(commandBuffer: inout MTLCommandBuffer, originalTexture: inout MCTexture, overTexture: inout MCTexture, destinationTexture: inout MCTexture, renderSize: CGSize) throws {

            let encoder: MTLComputeCommandEncoder = commandBuffer.makeComputeCommandEncoder()!
            encoder.setComputePipelineState(self.pipeline)
            encoder.setTexture(originalTexture.texture, index: Int(OriginalTextureIndex.rawValue))
            encoder.setTexture(overTexture.texture, index: Int(OverTextureIndex.rawValue))
            encoder.setTexture(destinationTexture.texture, index: Int(DestinationTextureIndex.rawValue))
            encoder.endEncoding()
        }
    }
}

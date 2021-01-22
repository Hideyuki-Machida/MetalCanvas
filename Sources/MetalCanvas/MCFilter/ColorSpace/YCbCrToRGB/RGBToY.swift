//
//  RGBToY.swift
//  
//
//  Created by hideyuki machida on 2020/10/04.
//

import Foundation
import Metal

extension MCFilter.ColorSpace {
    public struct RGBToY {
        // MARK: - vars

        fileprivate let pipelineState: MTLComputePipelineState
        fileprivate let threadsPerThreadgroup = MTLSize(width: 16, height: 16, depth: 1)
        
        // MARK: - func

        public init() throws {
            self.pipelineState = try MCCore.device.makeComputePipelineState(function: MCFilter.ColorSpace.RGBToY.shaderFunc.kernel)
        }

        public func process(commandBuffer: MTLCommandBuffer, sorceRGB: MCTexture, destinationY: inout MCTexture) throws {

            let threadgroupCount = MTLSize(
                width: Int(sorceRGB.size.w) / self.threadsPerThreadgroup.width,
                height: Int(sorceRGB.size.h) / self.threadsPerThreadgroup.height,
                depth: 1
            )

            let encoder: MTLComputeCommandEncoder = commandBuffer.makeComputeCommandEncoder()!
            encoder.setComputePipelineState(self.pipelineState)
            encoder.setTexture(sorceRGB.texture, index: 0)
            encoder.setTexture(destinationY.texture, index: 1)
            encoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
}

extension MCFilter.ColorSpace.RGBToY {
    // MARK: - MTLFunction

    private static let shaderFunc: ShaderFunc = MCFilter.ColorSpace.RGBToY.ShaderFunc()

    fileprivate struct ShaderFunc {
        fileprivate let kernel: MTLFunction = MCCore.library.makeFunction(name: "kernel_RGBToY")!
    }
}

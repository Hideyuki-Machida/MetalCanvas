//
//  MCFilterYCbCrToRGB.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/03.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation
import Metal

extension MCFilter.ColorSpace {
    public struct YCbCrToRGB {
        // MARK: - vars

        fileprivate let pipelineState: MTLComputePipelineState
        fileprivate let threadsPerThreadgroup = MTLSize(width: 16, height: 16, depth: 1)

        // MARK: - func

        public init() throws {
            self.pipelineState = try MCCore.device.makeComputePipelineState(function: MCFilter.ColorSpace.YCbCrToRGB.shaderFunc.kernel)
        }

        public func process(commandBuffer: MTLCommandBuffer, sorceY: inout MCTexture, sorceCbCr: inout MCTexture, destinationRGB: inout MCTexture) throws {

            let threadgroupCount = MTLSize(
                width: Int(sorceY.size.w) / self.threadsPerThreadgroup.width,
                height: Int(sorceY.size.h) / self.threadsPerThreadgroup.height,
                depth: 1
            )

            let encoder: MTLComputeCommandEncoder = commandBuffer.makeComputeCommandEncoder()!
            encoder.setComputePipelineState(self.pipelineState)
            encoder.setTexture(sorceY.texture, index: 0)
            encoder.setTexture(sorceCbCr.texture, index: 1)
            encoder.setTexture(destinationRGB.texture, index: 2)
            encoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
}

extension MCFilter.ColorSpace.YCbCrToRGB {
    // MARK: - MTLFunction

    private static let shaderFunc: ShaderFunc = MCFilter.ColorSpace.YCbCrToRGB.ShaderFunc()

    fileprivate struct ShaderFunc {
        fileprivate let kernel: MTLFunction = MCCore.library.makeFunction(name: "kernel_YCbCrToRGB")!
    }
}

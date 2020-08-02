//
//  RGBToYCbCr.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2020/07/22.
//  Copyright © 2020 hideyuki machida. All rights reserved.

import Foundation
import Metal

extension MCFilter.ColorSpace {
    public struct YCbCrToRGBYCbCr {
        // MARK: - vars

        fileprivate let pipelineState: MTLComputePipelineState
        fileprivate let threadsPerThreadgroup = MTLSize(width: 16, height: 16, depth: 1)

        // MARK: - func

        public init() throws {
            self.pipelineState = try MCCore.device.makeComputePipelineState(function: MCFilter.ColorSpace.YCbCrToRGBYCbCr.shaderFunc.kernel)
        }

        public func process(commandBuffer: MTLCommandBuffer, sorceY: inout MCTexture, sorceCbCr: inout MCTexture, destinationRGB: inout MCTexture, destinationY: inout MCTexture, destinationCb: inout MCTexture, destinationCr: inout MCTexture) throws {

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
            encoder.setTexture(destinationY.texture, index: 3)
            encoder.setTexture(destinationCb.texture, index: 4)
            encoder.setTexture(destinationCr.texture, index: 5)
            encoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
}

extension MCFilter.ColorSpace.YCbCrToRGBYCbCr {
    // MARK: - MTLFunction

    private static let shaderFunc: ShaderFunc = ShaderFunc()

    fileprivate struct ShaderFunc {
        fileprivate let kernel: MTLFunction = MCCore.library.makeFunction(name: "kernel_YCbCrToRGBYCbCr")!
    }
}

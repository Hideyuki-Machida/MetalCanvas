//
//  RGBToYCbCr.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2020/07/22.
//  Copyright © 2020 hideyuki machida. All rights reserved.

import Foundation
import Metal

extension MCFilter.ColorSpace {
    public struct RGBToYCbCr {
        // MARK: - vars

        fileprivate let pipelineState: MTLComputePipelineState
        fileprivate let threadsPerThreadgroup = MTLSize(width: 16, height: 16, depth: 1)
        
        // MARK: - func

        public init() throws {
            self.pipelineState = try MCCore.device.makeComputePipelineState(function: MCFilter.ColorSpace.RGBToYCbCr.shaderFunc.kernel)
            //self.pipelineState.label = "MCFilter.ColorSpace RGBToYCbCr"
        }

        public func process(commandBuffer: MTLCommandBuffer, sorceRGB: inout MCTexture, destinationY: inout MCTexture, destinationCb: inout MCTexture, destinationCr: inout MCTexture) throws {

            let threadgroupCount = MTLSize(
                width: Int(sorceRGB.size.w) / self.threadsPerThreadgroup.width,
                height: Int(sorceRGB.size.h) / self.threadsPerThreadgroup.height,
                depth: 1
            )

            let encoder: MTLComputeCommandEncoder = commandBuffer.makeComputeCommandEncoder()!
            encoder.setComputePipelineState(self.pipelineState)
            encoder.setTexture(sorceRGB.texture, index: 0)
            encoder.setTexture(destinationY.texture, index: 1)
            encoder.setTexture(destinationCb.texture, index: 2)
            encoder.setTexture(destinationCr.texture, index: 3)
            encoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
}

extension MCFilter.ColorSpace.RGBToYCbCr {
    // MARK: - MTLFunction

    private static let shaderFunc: ShaderFunc = MCFilter.ColorSpace.RGBToYCbCr.ShaderFunc()

    fileprivate struct ShaderFunc {
        fileprivate let kernel: MTLFunction = MCCore.library.makeFunction(name: "kernel_RGBToYCbCr")!
    }
}

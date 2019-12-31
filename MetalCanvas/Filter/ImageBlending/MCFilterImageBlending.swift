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
        // MARK: - vars

        private let pipeline: MTLComputePipelineState

        // MARK: - func

        public init(mode: MCFilter.ImageBlending.ImageBlendingMode) throws {
            let function: MTLFunction = mode.kernel
            self.pipeline = try MCCore.device.makeComputePipelineState(function: function)
        }

        public func process(commandBuffer: inout MTLCommandBuffer, originalTexture: inout MCTexture, overTexture: inout MCTexture, destinationTexture: inout MCTexture, renderSize: CGSize) throws {
            guard let encoder: MTLComputeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else { throw ErrorType.drawError }
            encoder.setComputePipelineState(self.pipeline)
            encoder.setTexture(originalTexture.texture, index: Int(OriginalTextureIndex.rawValue))
            encoder.setTexture(overTexture.texture, index: Int(OverTextureIndex.rawValue))
            encoder.setTexture(destinationTexture.texture, index: Int(DestinationTextureIndex.rawValue))
            encoder.endEncoding()
        }
    }
}

extension MCFilter.ImageBlending {
    private static let shaderFunc: ShaderFunc = MCFilter.ImageBlending.ShaderFunc()

    fileprivate struct ShaderFunc {
        fileprivate let kernelAlphaBlending: MTLFunction = MCCore.library.makeFunction(name: "kernel_imageBlending_alphaBlending")!
        fileprivate let kernelDepthBlending: MTLFunction = MCCore.library.makeFunction(name: "kernel_imageBlending_depthBlending")!
    }

    public enum ImageBlendingMode {
        case alphaBlending
        case depthBlending

        public var kernel: MTLFunction {
            switch self {
            case .alphaBlending: return MCFilter.ImageBlending.shaderFunc.kernelAlphaBlending
            case .depthBlending: return MCFilter.ImageBlending.shaderFunc.kernelDepthBlending
            }
        }
    }
}

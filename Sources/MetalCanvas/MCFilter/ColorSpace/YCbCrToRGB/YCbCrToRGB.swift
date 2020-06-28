//
//  MCFilterYCbCrToRGB.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/03.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation
import Metal
import CoreGraphics
import MetalCanvasShaders

extension MCFilter.ColorSpace {
    public struct YCbCrToRGB {
        // MARK: - vars

        fileprivate let pipelineState: MCPipelineState
        fileprivate let vertexInBuffer: MTLBuffer

        // MARK: - func

        public init() throws {
            self.pipelineState = try MCPipelineState(
                vertex: MCFilter.ColorSpace.YCbCrToRGB.shaderFunc.vertex,
                fragment: MCFilter.ColorSpace.YCbCrToRGB.shaderFunc.fragment,
                label: "MCFilter.ColorSpace YCbCrToRGB"
            )

            self.vertexInBuffer = try MCCore.makeBuffer(data: MCShaderPreset.normalizedVertex)
        }

        public func process(commandBuffer: MTLCommandBuffer, capturedImageTextureY: inout MCTexture, capturedImageTextureCbCr: inout MCTexture, renderPassDescriptor: MTLRenderPassDescriptor, renderSize: CGSize) throws {
            guard let renderCommandEncoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { throw MCFilter.ErrorType.drawError }
            renderCommandEncoder.setRenderPipelineState(self.pipelineState.renderPipelineState)
            renderCommandEncoder.setVertexBuffer(self.vertexInBuffer, offset: 0, index: Int(MCVertexIndex.rawValue))
            renderCommandEncoder.setFragmentTexture(capturedImageTextureY.texture, index: 0)
            renderCommandEncoder.setFragmentTexture(capturedImageTextureCbCr.texture, index: 1)
            renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            renderCommandEncoder.endEncoding()
        }
    }
}

extension MCFilter.ColorSpace.YCbCrToRGB {
    // MARK: - MTLFunction

    private static let shaderFunc: ShaderFunc = MCFilter.ColorSpace.YCbCrToRGB.ShaderFunc()

    fileprivate struct ShaderFunc {
        fileprivate let kernel: MTLFunction = MCCore.library.makeFunction(name: "kernel_YCbCrToRGB")!
        fileprivate let vertex: MTLFunction = MCCore.library.makeFunction(name: "vertex_YCbCrToRGB")!
        fileprivate let fragment: MTLFunction = MCCore.library.makeFunction(name: "fragment_YCbCrToRGB")!
    }
}

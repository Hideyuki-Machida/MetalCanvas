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
        fileprivate let pipelineState: MCPipelineState
        fileprivate let vertexInBuffer: MTLBuffer

        public init () throws {
            self.pipelineState = try MCPipelineState.init(
                vertex: MCFunction.ColorSpace.YCbCrToRGB.vertex,
                fragment: MCFunction.ColorSpace.YCbCrToRGB.fragment,
                label: "MCFilter.ColorSpace YCbCrToRGB"
            )

            self.vertexInBuffer = try MCCore.makeBuffer(data: MCShaderPreset.normalizedVertex)
        }
        
        public func process(commandBuffer: inout MTLCommandBuffer, capturedImageTextureY: inout MCTexture, capturedImageTextureCbCr: inout MCTexture, renderPassDescriptor: MTLRenderPassDescriptor, renderSize: CGSize) throws {
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

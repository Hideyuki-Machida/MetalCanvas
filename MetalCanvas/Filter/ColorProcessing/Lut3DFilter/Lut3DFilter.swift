//
//  LutFilter.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/02/24.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation
import MetalKit

extension MCFilter.ColorProcessing {
    public struct Lut3DFilter {
        // MARK: - vars

        fileprivate let pipelineState: MCPipelineState
        fileprivate let vertexInBuffer: MTLBuffer
        fileprivate var intensityBuffer: MTLBuffer

        fileprivate var renderPassDescriptor: MTLRenderPassDescriptor = MTLRenderPassDescriptor()
        private var lutImageTexture: MCTexture

        public var intensity: Float = 1.0 {
            willSet {
                do {
                    self.intensityBuffer = try MCCore.makeBuffer(data: [newValue])
                } catch {}
            }
        }

        // MARK: - func

        public init(lutImageTexture: MCTexture) throws {
            self.lutImageTexture = lutImageTexture

            self.pipelineState = try MCPipelineState(
                vertex: MCFilter.ColorProcessing.Lut3DFilter.shaderFunc.vertex,
                fragment: MCFilter.ColorProcessing.Lut3DFilter.shaderFunc.fragment,
                label: "MCPrimitive Image"
            )
            self.vertexInBuffer = try MCCore.makeBuffer(data: MCShaderPreset.normalizedVertex)
            self.intensityBuffer = try MCCore.makeBuffer(data: [self.intensity])

            self.renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
            self.renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        }

        public func process(commandBuffer: MTLCommandBuffer, imageTexture: MCTexture, destinationTexture: inout MCTexture) throws {
            self.renderPassDescriptor.colorAttachments[0].texture = destinationTexture.texture

            guard let renderCommandEncoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { throw MCFilter.ErrorType.drawError }
            renderCommandEncoder.setRenderPipelineState(self.pipelineState.renderPipelineState)
            renderCommandEncoder.setVertexBuffer(self.vertexInBuffer, offset: 0, index: Int(MCVertexIndex.rawValue))
            renderCommandEncoder.setFragmentTexture(imageTexture.texture, index: 0)
            renderCommandEncoder.setFragmentTexture(self.lutImageTexture.texture, index: 1)
            renderCommandEncoder.setFragmentBuffer(self.intensityBuffer, offset: 0, index: Int(MCIntensity.rawValue))
            renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            renderCommandEncoder.endEncoding()
        }
    }
}

extension MCFilter.ColorProcessing.Lut3DFilter {
    // MARK: - MTLFunction

    private static let shaderFunc: ShaderFunc = MCFilter.ColorProcessing.Lut3DFilter.ShaderFunc()

    fileprivate struct ShaderFunc {
        fileprivate let vertex: MTLFunction = MCCore.library.makeFunction(name: "vertex_Lut3DFilter")!
        fileprivate let fragment: MTLFunction = MCCore.library.makeFunction(name: "fragment_Lut3DFilter")!
    }
}

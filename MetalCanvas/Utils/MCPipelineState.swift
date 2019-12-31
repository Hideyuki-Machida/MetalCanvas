//
//  MCPipelineState.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/10/26.
//  Copyright © 2019 Donuts. All rights reserved.
//

import Foundation

public struct MCPipelineState {
    public let renderPipelineState: MTLRenderPipelineState
    public init(vertex: MTLFunction, fragment: MTLFunction, label: String, pixelFormat: MTLPixelFormat = .bgra8Unorm) throws {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.label = label
        renderPipelineDescriptor.vertexFunction = vertex
        renderPipelineDescriptor.fragmentFunction = fragment
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        self.renderPipelineState = try MCCore.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    }
}

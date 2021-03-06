//
//  MCRenderPipelineState.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/10/26.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation
import Metal

public struct MCRenderPipelineState {
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

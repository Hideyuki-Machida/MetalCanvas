//
//  MCImageRenderView.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2018/12/29.
//  Copyright © 2018 hideyuki machida. All rights reserved.
//

import Metal
import MetalKit
import MetalPerformanceShaders
import AVFoundation

open class MCImageRenderView: MTKView, MTKViewDelegate {

    private let rect: CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.nativeBounds.size)
    private let hasHEVCHardwareEncoder: Bool = MCTools.hasHEVCHardwareEncoder
    public var drawRect: CGRect?
    public var trimRect: CGRect?
    public var pipeline: MTLComputePipelineState?
    public var pipeline0: MTLRenderPipelineState?

    private var _mathScale: CGSize = CGSize(width: 0, height: 0)
    private var filter: MPSImageLanczosScale!
    
    open override func awakeFromNib() {
        super.awakeFromNib()
    }

    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        
        self._init()
    }
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)

        self._init()
    }

    private func _init() {
        self.delegate = self
        self.device = MCCore.device
        self.filter = MPSImageLanczosScale(device: self.device!)
        
        self.isPaused = true
        self.framebufferOnly = false
        self.enableSetNeedsDisplay = false
        self.autoResizeDrawable = true
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    public func draw(in view: MTKView) {
    }

    open func setup() throws {
    }

    deinit {
        MCDebug.deinitLog(self)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
    }
}


extension MCImageRenderView {
    public func update001(texture: MTLTexture, renderSize: CGSize, queue: DispatchQueue?) {
        guard let commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer() else { return }
        if let queue = queue {
            queue.async { [weak self] in
                autoreleasepool() { [weak self] in
                    self?.updatePixelBuffer(commandBuffer: commandBuffer, texture: texture, renderSize: renderSize)
                }
            }
        } else {
            autoreleasepool() { [weak self] in
                self?.updatePixelBuffer(commandBuffer: commandBuffer, texture: texture, renderSize: renderSize)
            }
        }
    }

    public func update(commandBuffer: MTLCommandBuffer, texture: MTLTexture, renderSize: CGSize, queue: DispatchQueue?) {
        if let queue = queue {
            queue.async { [weak self] in
                autoreleasepool() { [weak self] in
                    self?.updatePixelBuffer(commandBuffer: commandBuffer, texture: texture, renderSize: renderSize)
                }
            }
        } else {
            autoreleasepool() { [weak self] in
                self?.updatePixelBuffer(commandBuffer: commandBuffer, texture: texture, renderSize: renderSize)
            }
        }
    }

    fileprivate func updatePixelBuffer(commandBuffer: MTLCommandBuffer, texture: MTLTexture, renderSize: CGSize) {
        ////////////////////////////////////////////////////////////
        //
        guard let drawable: CAMetalDrawable = self.currentDrawable else {
            commandBuffer.commit()
            return
        }
        var commandBuffer: MTLCommandBuffer = commandBuffer
        ////////////////////////////////////////////////////////////

        ////////////////////////////////////////////////////////////
        // drawableSizeを最適化
        self.drawableSize = renderSize
        ////////////////////////////////////////////////////////////
        
        if self.hasHEVCHardwareEncoder {
            // MPSが使える端末
            
            ////////////////////////////////////////////////////////////
            // previewScale encode
            let scale: Double = Double(drawable.texture.width) / Double(texture.width)
            var transform: MPSScaleTransform = MPSScaleTransform(scaleX: scale, scaleY: scale, translateX: 0, translateY: 0)
            withUnsafePointer(to: &transform) { [weak self] (transformPtr: UnsafePointer<MPSScaleTransform>) -> () in
                self?.filter.scaleTransform = transformPtr
                self?.filter.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: drawable.texture)
            }
            ////////////////////////////////////////////////////////////

            ////////////////////////////////////////////////////////////
            // commit
            commandBuffer.present(drawable)
            commandBuffer.commit()
            self.draw()
            ////////////////////////////////////////////////////////////
        } else {
            // MPSが使えない端末

            do {
                defer { commandBuffer.commit() }
                ////////////////////////////////////////////////////////////
                // previewScale encode
                let texture: MCTexture = try MCTexture.init(texture: texture)
                var mcTexture01: MCTexture = try MCTexture.init(texture: drawable.texture)
                let scale: Float = Float(mcTexture01.width) / Float(texture.width)
                let canvas: MCCanvas = try MCCanvas.init(destination: &mcTexture01, orthoType: MCCanvas.OrthoType.topLeft)
                let imageMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4.init(scaleX: scale, scaleY: scale, scaleZ: 1.0)
                
                try canvas.draw(commandBuffer: &commandBuffer, objects: [
                    try MCPrimitive.Image.init(
                        texture: texture,
                        ppsition: SIMD3<Float>.init(x: Float(mcTexture01.width) / 2.0, y: Float(mcTexture01.height) / 2.0, z: 0),
                        transform: imageMat,
                        anchorPoint: .center
                    )
                ])
                ////////////////////////////////////////////////////////////
                
                ////////////////////////////////////////////////////////////
                // commit
                commandBuffer.present(drawable)
                self.draw()
                ////////////////////////////////////////////////////////////

            } catch {
                MCDebug.log("updatePixelBuffer error")
            }
        }
        
    }

}

extension MCImageRenderView {
    public func update(texture: MCTexture, renderSize: CGSize, queue: DispatchQueue?) {
        guard let commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer() else { return }
        if let queue = queue {
            queue.async { [weak self] in
                autoreleasepool() { [weak self] in
                    self?.updatePixelBuffer(commandBuffer: commandBuffer, texture: texture, renderSize: renderSize)
                }
            }
        } else {
            autoreleasepool() { [weak self] in
                self?.updatePixelBuffer(commandBuffer: commandBuffer, texture: texture, renderSize: renderSize)
            }
        }
    }
    
    public func update(commandBuffer: MTLCommandBuffer, texture: MCTexture, renderSize: CGSize, queue: DispatchQueue?) {
        if let queue = queue {
            queue.async { [weak self] in
                autoreleasepool() { [weak self] in
                    self?.updatePixelBuffer(commandBuffer: commandBuffer, texture: texture, renderSize: renderSize)
                }
            }
        } else {
            self.updatePixelBuffer(commandBuffer: commandBuffer, texture: texture, renderSize: renderSize)
        }
    }

    private func updatePixelBuffer(commandBuffer: MTLCommandBuffer, texture: MCTexture, renderSize: CGSize) {
        ////////////////////////////////////////////////////////////
        //
        guard let drawable: CAMetalDrawable = self.currentDrawable else { return }
        var commandBuffer: MTLCommandBuffer = commandBuffer
        ////////////////////////////////////////////////////////////

        if self.hasHEVCHardwareEncoder {
            ////////////////////////////////////////////////////////////
            // previewScale encode
            let scale: Double = Double(drawable.texture.width) / Double(texture.width)
            var transform: MPSScaleTransform = MPSScaleTransform(scaleX: scale, scaleY: scale, translateX: 0, translateY: 0)
            withUnsafePointer(to: &transform) { [weak self] (transformPtr: UnsafePointer<MPSScaleTransform>) -> () in
                self?.filter.scaleTransform = transformPtr
                self?.filter.encode(commandBuffer: commandBuffer, sourceTexture: texture.texture, destinationTexture: drawable.texture)
            }
            ////////////////////////////////////////////////////////////

            ////////////////////////////////////////////////////////////
            // commit
            commandBuffer.present(drawable)
            commandBuffer.commit()
            self.draw()
            ////////////////////////////////////////////////////////////
        } else {
            do {
                ////////////////////////////////////////////////////////////
                // previewScale encode
                var mcTexture01: MCTexture = try MCTexture.init(texture: drawable.texture)
                let scale: Float = Float(mcTexture01.width) / Float(texture.width)
                let canvas: MCCanvas = try MCCanvas.init(destination: &mcTexture01, orthoType: MCCanvas.OrthoType.topLeft)
                let imageMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4.init(scaleX: scale, scaleY: scale, scaleZ: 1.0)
                
                try canvas.draw(commandBuffer: &commandBuffer, objects: [
                    try MCPrimitive.Image.init(
                        texture: texture,
                        ppsition: SIMD3<Float>.init(x: Float(mcTexture01.width) / 2.0, y: Float(mcTexture01.height) / 2.0, z: 0),
                        transform: imageMat,
                        anchorPoint: .center
                    )
                ])
                ////////////////////////////////////////////////////////////
                
                ////////////////////////////////////////////////////////////
                // commit
                commandBuffer.present(drawable)
                commandBuffer.commit()
                self.draw()
                ////////////////////////////////////////////////////////////

            } catch {
                commandBuffer.commit()
            }
        }

    }
}

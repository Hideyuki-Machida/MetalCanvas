//
//  MCImageRenderView.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2018/12/29.
//  Copyright © 2018 Donuts. All rights reserved.
//

import AVFoundation
import Metal
import MetalKit
import MetalPerformanceShaders

open class MCImageRenderView: MTKView {
    private let hasMPS: Bool = MCTools.shard.hasMPS
    public var drawRect: CGRect?
    public var trimRect: CGRect?

    private var filter: MPSImageLanczosScale!

    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        self._init()
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        self._init()
    }

    private func _init() {
        self.delegate = self

        self.framebufferOnly = false
        self.enableSetNeedsDisplay = false
        self.autoResizeDrawable = true
    }

    open func setup() throws {
        guard MCCore.isMetalCanvas else { throw MCCore.MCCoreErrorType.setup }
        self.device = MCCore.device
        self.filter = MPSImageLanczosScale(device: MCCore.device)
    }

    deinit {
        self.releaseDrawables()
        MCDebug.deinitLog(self)
    }
}

extension MCImageRenderView {
    public func update(texture: MTLTexture, renderSize: CGSize, queue: DispatchQueue?) {
        guard let commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer() else { return }
        if let queue = queue {
            queue.async { [weak self] in
                autoreleasepool { [weak self] in
                    self?.updatePixelBuffer(commandBuffer: commandBuffer, texture: texture, renderSize: renderSize)
                }
            }
        } else {
            autoreleasepool { [weak self] in
                self?.updatePixelBuffer(commandBuffer: commandBuffer, texture: texture, renderSize: renderSize)
            }
        }
    }

    public func update(commandBuffer: MTLCommandBuffer, texture: MTLTexture, renderSize: CGSize, queue: DispatchQueue?) {
        if let queue = queue {
            queue.async { [weak self] in
                autoreleasepool { [weak self] in
                    self?.updatePixelBuffer(commandBuffer: commandBuffer, texture: texture, renderSize: renderSize)
                }
            }
        } else {
            autoreleasepool { [weak self] in
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

        if self.hasMPS {
            // MPSが使える端末

            ////////////////////////////////////////////////////////////
            // previewScale encode
            let scale: Double = Double(drawable.texture.width) / Double(texture.width)
            var transform: MPSScaleTransform = MPSScaleTransform(scaleX: scale, scaleY: scale, translateX: 0, translateY: 0)
            withUnsafePointer(to: &transform) { [weak self] (transformPtr: UnsafePointer<MPSScaleTransform>) -> Void in
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
                let sourceTexture: MCTexture = try MCTexture(texture: texture)
                var drawableTexture: MCTexture = try MCTexture(texture: drawable.texture)
                let scale: Float = Float(drawableTexture.width) / Float(sourceTexture.width)
                let canvas: MCCanvas = try MCCanvas(destination: &drawableTexture, orthoType: MCCanvas.OrthoType.topLeft)
                let imageMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4(scaleX: scale, scaleY: scale, scaleZ: 1.0)

                try canvas.draw(commandBuffer: &commandBuffer, objects: [
                    try MCPrimitive.Image(
                        texture: sourceTexture,
                        position: SIMD3<Float>(x: Float(drawableTexture.width) / 2.0, y: Float(drawableTexture.height) / 2.0, z: 0),
                        transform: imageMat,
                        anchorPoint: .center
                    ),
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
                autoreleasepool { [weak self] in
                    self?.updatePixelBuffer(commandBuffer: commandBuffer, texture: texture, renderSize: renderSize)
                }
            }
        } else {
            autoreleasepool { [weak self] in
                self?.updatePixelBuffer(commandBuffer: commandBuffer, texture: texture, renderSize: renderSize)
            }
        }
    }

    public func update(commandBuffer: MTLCommandBuffer, texture: MCTexture, renderSize: CGSize, queue: DispatchQueue?) {
        if let queue = queue {
            queue.async { [weak self] in
                autoreleasepool { [weak self] in
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

        if self.hasMPS {
            ////////////////////////////////////////////////////////////
            // previewScale encode
            let scale: Double = Double(drawable.texture.width) / Double(texture.width)
            var transform: MPSScaleTransform = MPSScaleTransform(scaleX: scale, scaleY: scale, translateX: 0, translateY: 0)
            withUnsafePointer(to: &transform) { [weak self] (transformPtr: UnsafePointer<MPSScaleTransform>) -> Void in
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
                var drawableTexture: MCTexture = try MCTexture(texture: drawable.texture)
                let scale: Float = Float(drawableTexture.width) / Float(texture.width)
                let canvas: MCCanvas = try MCCanvas(destination: &drawableTexture, orthoType: MCCanvas.OrthoType.topLeft)
                let imageMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4(scaleX: scale, scaleY: scale, scaleZ: 1.0)

                try canvas.draw(commandBuffer: &commandBuffer, objects: [
                    try MCPrimitive.Image(
                        texture: texture,
                        position: SIMD3<Float>(x: Float(drawableTexture.width) / 2.0, y: Float(drawableTexture.height) / 2.0, z: 0),
                        transform: imageMat,
                        anchorPoint: .center
                    ),
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

extension MCImageRenderView {
    public func updatePixelBuffer(commandBuffer: MTLCommandBuffer, source: MTLTexture, destination: MTLTexture, renderSize: CGSize) {
        ////////////////////////////////////////////////////////////
        //
        var commandBuffer: MTLCommandBuffer = commandBuffer
        ////////////////////////////////////////////////////////////
        if self.hasMPS {
            ////////////////////////////////////////////////////////////
            // previewScale encode
            let scale: Double = Double(destination.width) / Double(source.width)
            var transform: MPSScaleTransform = MPSScaleTransform(scaleX: scale, scaleY: scale, translateX: 0, translateY: 0)
            withUnsafePointer(to: &transform) { [weak self] (transformPtr: UnsafePointer<MPSScaleTransform>) -> Void in
                self?.filter.scaleTransform = transformPtr
                self?.filter.encode(commandBuffer: commandBuffer, sourceTexture: source, destinationTexture: destination)
            }
            ////////////////////////////////////////////////////////////
        } else {
            do {
                ////////////////////////////////////////////////////////////
                // previewScale encode
                let texture: MCTexture = try MCTexture(texture: source)
                var destinationTexture: MCTexture = try MCTexture(texture: destination)
                let scale: Float = Float(destinationTexture.width) / Float(texture.width)
                let canvas: MCCanvas = try MCCanvas(destination: &destinationTexture, orthoType: MCCanvas.OrthoType.topLeft)
                let imageMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4(scaleX: scale, scaleY: scale, scaleZ: 1.0)

                try canvas.draw(commandBuffer: &commandBuffer, objects: [
                    try MCPrimitive.Image(
                        texture: texture,
                        position: SIMD3<Float>(x: Float(destinationTexture.width) / 2.0, y: Float(destinationTexture.height) / 2.0, z: 0),
                        transform: imageMat,
                        anchorPoint: .center
                    ),
                ])
                ////////////////////////////////////////////////////////////
            } catch {
                MCDebug.log("updatePixelBuffer error")
            }
        }
    }
}

extension MCImageRenderView {
    public func drawUpdate(drawTexture: MTLTexture) {
        ////////////////////////////////////////////////////////////
        // drawableSizeを最適化
        self.drawableSize = CGSize(CGFloat(drawTexture.width), CGFloat(drawTexture.height))
        ////////////////////////////////////////////////////////////

        guard
            let commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer(),
            let drawable: CAMetalDrawable = self.currentDrawable,
            drawable.texture.width == drawTexture.width, drawable.texture.height == drawTexture.height
        else { return }

        ///////////////////////////////////////////////////////////////////////////////////////////
        // ブリットエンコード
        let blitEncoder: MTLBlitCommandEncoder? = commandBuffer.makeBlitCommandEncoder()
        blitEncoder?.copy(from: drawTexture,
                          sourceSlice: 0,
                          sourceLevel: 0,
                          sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                          sourceSize: MTLSizeMake(drawable.texture.width, drawable.texture.height, drawable.texture.depth),
                          to: drawable.texture,
                          destinationSlice: 0,
                          destinationLevel: 0,
                          destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        blitEncoder?.endEncoding()
        ///////////////////////////////////////////////////////////////////////////////////////////

        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}

extension MCImageRenderView: MTKViewDelegate {
    open func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    open func draw(in view: MTKView) {}
}

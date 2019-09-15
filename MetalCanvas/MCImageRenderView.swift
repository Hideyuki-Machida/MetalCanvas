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
	private let hasHEVCHardwareEncoder: Bool = Tools.hasHEVCHardwareEncoder
	public var drawRect: CGRect?
	public var trimRect: CGRect?
	public var pipeline: MTLComputePipelineState?
	public var pipeline0: MTLRenderPipelineState?
	
	private var _mathScale: CGSize = CGSize(width: 0, height: 0)
	private var filter: MPSImageLanczosScale!
	
	open override func awakeFromNib() {
		super.awakeFromNib()
		self.delegate = self
		self.device = MCCore.device
		self.filter = MPSImageLanczosScale(device: self.device!)
		
		self.isPaused = true
		self.framebufferOnly = false
		self.enableSetNeedsDisplay = false
	}
	
	public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
	}
	
	public func draw(in view: MTKView) {
		//print(view.preferredFramesPerSecond)
		/*
		guard let image: CIImage = self.image else { return }
		guard let commandQueue: MTLCommandQueue = self.commandQueue else { return }
		let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer()
		let bounds = CGRect( x: 0, y: 0, width: (self.bounds.size.width), height: (self.bounds.size.height) )
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		self.ciContext?.render(image, to: self.currentDrawable!.texture, commandBuffer: commandBuffer, bounds: image.extent, colorSpace: colorSpace)
		commandBuffer.present(self.currentDrawable!)
		commandBuffer.commit()
		commandBuffer.waitUntilCompleted()
		*/
		
	}
	
	func setup() {
	}
	
	deinit {
		//Debug.VideoActionLog("deinit: ImageRenderView")
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
	}
	

}


extension MCImageRenderView {
	public func update(texture: MTLTexture, renderSize: CGSize, queue: DispatchQueue?) {
		//var texture: MTLTexture = texture
		guard var commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer() else { return }
		if let queue = queue {
			queue.async { [weak self] in
				autoreleasepool() { [weak self] in
					self?.updatePixelBuffer(commandBuffer: &commandBuffer, texture: texture, renderSize: renderSize)
				}
			}
		} else {
			autoreleasepool() { [weak self] in
				self?.updatePixelBuffer(commandBuffer: &commandBuffer, texture: texture, renderSize: renderSize)
			}
		}
	}
	
	public func update(commandBuffer: inout MTLCommandBuffer, texture: MTLTexture, renderSize: CGSize, queue: DispatchQueue?) {
		var commandBuffer: MTLCommandBuffer = commandBuffer
		//var texture: MTLTexture = texture
		if let queue = queue {
			queue.async { [weak self] in
				autoreleasepool() { [weak self] in
					self?.updatePixelBuffer(commandBuffer: &commandBuffer, texture: texture, renderSize: renderSize)
				}
			}
		} else {
			autoreleasepool() { [weak self] in
				self?.updatePixelBuffer(commandBuffer: &commandBuffer, texture: texture, renderSize: renderSize)
			}
		}
	}
	
	fileprivate func updatePixelBuffer(commandBuffer: inout MTLCommandBuffer, texture: MTLTexture, renderSize: CGSize) {
		////////////////////////////////////////////////////////////
		//
		guard let drawable: CAMetalDrawable = self.currentDrawable else {
			commandBuffer.commit()
			return
		}
		var commandBuffer: MTLCommandBuffer = commandBuffer
		////////////////////////////////////////////////////////////

		////////////////////////////////////////////////////////////
		//
		do {
			self.drawableSize = renderSize

			if drawable.texture.width != texture.width || drawable.texture.height != texture.height {
				if drawable.texture.width < texture.width || drawable.texture.height < texture.height {
					guard let cb: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer() else { return }
					let t: MCTexture = try MCTexture.init(renderSize: CGSize.init(width: drawable.texture.width, height: drawable.texture.height))
					let blitEncoder: MTLBlitCommandEncoder? = cb.makeBlitCommandEncoder()
					blitEncoder?.copy(from: t.texture,
									 sourceSlice: 0,
									 sourceLevel: 0,
									 sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
									 sourceSize: MTLSizeMake(drawable.texture.width, drawable.texture.height, t.texture.depth),
									 to: drawable.texture,
									 destinationSlice: 0,
									 destinationLevel: 0,
									 destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
					blitEncoder?.endEncoding()
					cb.addCompletedHandler { [weak self] (cb) in
						self?.draw()
						guard let drawable: CAMetalDrawable = self?.currentDrawable else {
							commandBuffer.commit()
							return
						}
						self?.updatePixelBuffer002(commandBuffer: &commandBuffer, drawable: drawable, texture: texture, renderSize: renderSize)
					}
					cb.present(drawable)
					cb.commit()
				} else {
					guard let cb: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer() else { return }
					let t: MCTexture = try MCTexture.init(renderSize: CGSize.init(width: renderSize.width, height: renderSize.height))
					let blitEncoder: MTLBlitCommandEncoder? = cb.makeBlitCommandEncoder()
					blitEncoder?.copy(from: t.texture,
									 sourceSlice: 0,
									 sourceLevel: 0,
									 sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
									 sourceSize: MTLSizeMake(t.width, t.height, t.texture.depth),
									 to: drawable.texture,
									 destinationSlice: 0,
									 destinationLevel: 0,
									 destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
					blitEncoder?.endEncoding()
					cb.addCompletedHandler { [weak self] (cb) in
						self?.draw()
						guard let drawable: CAMetalDrawable = self?.currentDrawable else {
							commandBuffer.commit()
							return
						}
						self?.updatePixelBuffer002(commandBuffer: &commandBuffer, drawable: drawable, texture: texture, renderSize: renderSize)
					}
					cb.present(drawable)
					cb.commit()
				}
			} else {
				self.updatePixelBuffer002(commandBuffer: &commandBuffer, drawable: drawable, texture: texture, renderSize: renderSize)
			}
		} catch {
			commandBuffer.commit()
		}
	}
	
	fileprivate func updatePixelBuffer002(commandBuffer: inout MTLCommandBuffer, drawable: CAMetalDrawable, texture: MTLTexture, renderSize: CGSize) {
		let blitEncoder: MTLBlitCommandEncoder? = commandBuffer.makeBlitCommandEncoder()
		blitEncoder?.copy(from: texture,
						 sourceSlice: 0,
						 sourceLevel: 0,
						 sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
						 sourceSize: MTLSizeMake(texture.width, texture.height, texture.depth),
						 to: drawable.texture,
						 destinationSlice: 0,
						 destinationLevel: 0,
						 destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
		blitEncoder?.endEncoding()

		commandBuffer.present(drawable)
		commandBuffer.commit()
		self.draw()
	}
}


extension MCImageRenderView {
	public func update(texture: MCTexture, renderSize: CGSize, queue: DispatchQueue?) {
		guard var commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer() else { return }
		if let queue = queue {
			queue.async { [weak self] in
				autoreleasepool() { [weak self] in
					self?.updatePixelBuffer(commandBuffer: &commandBuffer, texture: texture, renderSize: renderSize)
				}
			}
		} else {
			autoreleasepool() { [weak self] in
				self?.updatePixelBuffer(commandBuffer: &commandBuffer, texture: texture, renderSize: renderSize)
			}
		}
	}
	
	public func update(commandBuffer: inout MTLCommandBuffer, texture: MCTexture, renderSize: CGSize, queue: DispatchQueue?) {
		var commandBuffer: MTLCommandBuffer = commandBuffer
		if let queue = queue {
			queue.async { [weak self] in
				autoreleasepool() { [weak self] in
					self?.updatePixelBuffer(commandBuffer: &commandBuffer, texture: texture, renderSize: renderSize)
				}
			}
		} else {
			//autoreleasepool() { [weak self] in
				self.updatePixelBuffer(commandBuffer: &commandBuffer, texture: texture, renderSize: renderSize)
			//}
		}
	}

	private func updatePixelBuffer(commandBuffer: inout MTLCommandBuffer, texture: MCTexture, renderSize: CGSize) {
		////////////////////////////////////////////////////////////
		//
		guard let drawable: CAMetalDrawable = self.currentDrawable else { return }
		var commandBuffer: MTLCommandBuffer = commandBuffer
		////////////////////////////////////////////////////////////

		if self.hasHEVCHardwareEncoder {
			////////////////////////////////////////////////////////////
			// previewScale encode
			let scale: Double = Double(drawable.texture.width) / Double(texture.width)
			//let scale: Double = 1.5
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
						ppsition: MCGeom.Vec3D.init(x: Float(mcTexture01.width) / 2.0, y: Float(mcTexture01.height) / 2.0, z: 0),
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

extension MCImageRenderView {
	public func updatePixelBuffer(pixelBuffer: CVPixelBuffer, renderSize: CGSize, queue: DispatchQueue?) {
		if let queue = queue {
			queue.async { [weak self] in
				autoreleasepool() { [weak self] in
					//guard let self = self else { return }
					guard var commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer() else { return }
					self?.updatePixelBuffer(commandBuffer: &commandBuffer, pixelBuffer: pixelBuffer, renderSize: renderSize)
				}
			}
		} else {
			autoreleasepool() { [weak self] in
				//guard let self = self else { return }
				guard var commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer() else { return }
				self?.updatePixelBuffer(commandBuffer: &commandBuffer, pixelBuffer: pixelBuffer, renderSize: renderSize)
			}
		}
	}
	
	public func updatePixelBuffer(commandBuffer: inout MTLCommandBuffer, pixelBuffer: CVPixelBuffer, renderSize: CGSize, queue: DispatchQueue?) {
		var commandBuffer = commandBuffer
		if let queue = queue {
			queue.async { [weak self] in
				autoreleasepool() { [weak self] in
					//guard let self = self else { return }
					self?.updatePixelBuffer(commandBuffer: &commandBuffer, pixelBuffer: pixelBuffer, renderSize: renderSize)
				}
			}
		} else {
			autoreleasepool() { [weak self] in
				//guard let self = self else { return }
				self?.updatePixelBuffer(commandBuffer: &commandBuffer, pixelBuffer: pixelBuffer, renderSize: renderSize)
			}
		}
	}
	
	
	private func updatePixelBuffer(commandBuffer: inout MTLCommandBuffer, pixelBuffer: CVPixelBuffer, renderSize: CGSize) {
		////////////////////////////////////////////////////////////
		//
		guard let drawable: CAMetalDrawable = self.currentDrawable else { return }
		//guard var textureCache: CVMetalTextureCache = MCCore.textureCache else { return }
		var sourcePixelBuffer: CVPixelBuffer = pixelBuffer
		////////////////////////////////////////////////////////////
		
		//let texture: MTLTexture = MCCore.texture(pixelBuffer: &sourcePixelBuffer, textureCache: &textureCache, colorPixelFormat: self.colorPixelFormat)!
		////////////////////////////////////////////////////////////
		
		/*
		////////////////////////////////////////////////////////////
		// previewScale encode
		let scale: Double = Double(drawable.texture.width) / Double(texture.width)
		//let scale: Double = 1.5
		var transform: MPSScaleTransform = MPSScaleTransform(scaleX: scale, scaleY: scale, translateX: 0, translateY: 0)
		withUnsafePointer(to: &transform) { [weak self] (transformPtr: UnsafePointer<MPSScaleTransform>) -> () in
			self?.filter.scaleTransform = transformPtr
			self?.filter.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: drawable.texture)
		}
		////////////////////////////////////////////////////////////
		*/
		////////////////////////////////////////////////////////////
		// previewScale encode
		do {
			var mcTexture01: MCTexture = try MCTexture.init(texture: drawable.texture)
			let mcTexture02: MCTexture = try MCTexture.init(pixelBuffer: &sourcePixelBuffer, planeIndex: 1)
			let scale: Float = Float(mcTexture01.width) / Float(mcTexture02.width)
			let canvas: MCCanvas = try MCCanvas.init(destination: &mcTexture01, orthoType: MCCanvas.OrthoType.topLeft)
			let imageMat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4.init(scaleX: scale, scaleY: scale, scaleZ: 1.0)
			
			try canvas.draw(commandBuffer: &commandBuffer, objects: [
				try MCPrimitive.Image.init(
					texture: mcTexture02,
					ppsition: MCGeom.Vec3D.init(x: Float(mcTexture01.width) / 2.0, y: Float(mcTexture01.height) / 2.0, z: 0),
					transform: imageMat,
					anchorPoint: .center
				)
				])
		} catch {
			
		}
		////////////////////////////////////////////////////////////
		
		////////////////////////////////////////////////////////////
		// commit
		/*
		commandBuffer.addCompletedHandler { [weak self] (cb) in
			
		}
		*/
		commandBuffer.present(drawable)
		commandBuffer.commit()
		commandBuffer.waitUntilCompleted()
		self.draw()
		////////////////////////////////////////////////////////////
	}

}

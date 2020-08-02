//
//  DepthMapToTexture.swift
//  iOS_AVModule
//
//  Created by hideyuki machida on 2019/01/12.
//  Copyright © 2019 町田 秀行. All rights reserved.
//

import Foundation
import AVFoundation
import CoreImage
import GraphicsLibs_Swift

extension MCVision.Depth {
	public struct DepthMapTexture {
		public fileprivate(set) var texture: MCTexture?
		fileprivate var textureCache: CVMetalTextureCache? = MCCore.createTextureCache()
		fileprivate(set) var canvas: MCCanvas?
		fileprivate(set) var image: MCPrimitive.Image?
		
		public init () {}
		
		public mutating func update(to depthData: AVDepthData, renderSize: MCSize) throws {
			var depthPixelBuffer: CVPixelBuffer = depthData.depthDataMap
			let depthTexture: MCTexture = try MCTexture.init(pixelBuffer: depthPixelBuffer, planeIndex: 0)
			self.texture = depthTexture
		}

		public mutating func update(to depthData: AVDepthData, commandBuffer: inout MTLCommandBuffer, orientation: AVCaptureVideoOrientation, position: AVCaptureDevice.Position, renderSize: MCSize) throws {
			guard let textureCache: CVMetalTextureCache = self.textureCache else { throw MCVision.ErrorType.rendering }
			//////////////////////////////////////////////////////////
			// depthTexture 生成
			let depthPixelBuffer: CVPixelBuffer = depthData.depthDataMap
			//depthPixelBuffer.normalize()
			let depthWidth: Int = CVPixelBufferGetWidth(depthPixelBuffer)
			let depthHeight: Int = CVPixelBufferGetHeight(depthPixelBuffer)
            guard var newPixelBuffer: CVPixelBuffer = CVPixelBuffer.create(size: CGSize(w: CGFloat(depthWidth), h: CGFloat(depthHeight))) else { throw MCVision.ErrorType.rendering }
            let depthTexture: MCTexture = try MCTexture.init(pixelBuffer: newPixelBuffer, textureCache: textureCache, mtlPixelFormat: MTLPixelFormat.bgra8Unorm, planeIndex: 0)
			let depthImage: CIImage = CIImage(cvPixelBuffer: depthPixelBuffer, options: [:])
			let depthCloppdImage: CIImage = depthImage.clampedToExtent().cropped(to: depthImage.extent)
			MCCore.ciContext.render(depthCloppdImage, to: depthTexture.texture, commandBuffer: commandBuffer, bounds: depthCloppdImage.extent, colorSpace: depthImage.colorSpace!)
			//////////////////////////////////////////////////////////
			
			//////////////////////////////////////////////////////////
			// outTexture canvas 生成
			var outTexture: MCTexture
			if self.texture == nil {
                guard var newImageBuffer: CVImageBuffer = CVImageBuffer.create(size: CGSize(w: CGFloat(renderSize.w), h: CGFloat(renderSize.h))) else { return }
				outTexture = try MCTexture.init(pixelBuffer: newImageBuffer, textureCache: textureCache, mtlPixelFormat: MTLPixelFormat.bgra8Unorm, planeIndex: 0)
				self.canvas = try MCCanvas.init(destination: &outTexture, orthoType: .topLeft)
			} else {
				outTexture = self.texture!
				try self.canvas?.update(destination: &outTexture)
			}
			//////////////////////////////////////////////////////////
			
			//////////////////////////////////////////////////////////
			// Orientation変換
			var image: MCPrimitive.Image
			if self.image == nil {
				var mat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4.init()
				let angle: CGFloat = 90 * CGFloat.pi / 180
                mat.scale(x: renderSize.w / Float(depthTexture.size.h), y: renderSize.h / Float(depthTexture.size.w), z: 1.0)
                mat.rotateZ(radians: Float(angle))
                mat.translate(x: 0, y: -Float(depthTexture.size.h), z: 0.0)
                
                image = try MCPrimitive.Image.init(texture: depthTexture, position: SIMD3<Float>(x: 0.0, y: 0.0, z: 0.0), transform: mat, anchorPoint: MCPrimitive.Anchor.topLeft)

				self.image = image
			} else {
				image = self.image!
			}
			//image.texture = depthTexture
			try self.canvas?.draw(commandBuffer: commandBuffer, objects: [
				image,
				])
			//////////////////////////////////////////////////////////
			
			//////////////////////////////////////////////////////////
			// set
			self.texture = outTexture
			//////////////////////////////////////////////////////////
		}
		
	}
}

//
//  DepthMapToTexture.swift
//  iOS_AVModule
//
//  Created by hideyuki machida on 2019/01/12.
//  Copyright © 2019 町田 秀行. All rights reserved.
//

import Foundation
import AVFoundation

@available(iOS 11.0, *)
extension MCVision.Depth {
	public struct DepthMapTexture {
		public fileprivate(set) var texture: MCTexture?
		fileprivate var textureCache: CVMetalTextureCache? = MCCore.createTextureCache()
		fileprivate(set) var canvas: MCCanvas?
		fileprivate(set) var image: MCPrimitive.Image?
		
		public init () {}
		
		public mutating func update(to depthData: AVDepthData, renderSize: CGSize) throws {
			var depthPixelBuffer: CVPixelBuffer = depthData.depthDataMap
			let depthTexture: MCTexture = try MCTexture.init(pixelBuffer: &depthPixelBuffer, planeIndex: 0)
			self.texture = depthTexture
		}

		public mutating func update(to depthData: AVDepthData, commandBuffer: inout MTLCommandBuffer, orientation: AVCaptureVideoOrientation, position: AVCaptureDevice.Position, renderSize: CGSize) throws {
			guard var textureCache: CVMetalTextureCache = self.textureCache else { throw MCVision.ErrorType.rendering }
			//////////////////////////////////////////////////////////
			// depthTexture 生成
			let depthPixelBuffer: CVPixelBuffer = depthData.depthDataMap
			//depthPixelBuffer.normalize()
			let depthWidth: Int = CVPixelBufferGetWidth(depthPixelBuffer)
			let depthHeight: Int = CVPixelBufferGetHeight(depthPixelBuffer)
			guard var newPixelBuffer: CVPixelBuffer = CVPixelBuffer.create(size: CGSize.init(width: depthWidth, height: depthHeight)) else { throw MCVision.ErrorType.rendering }
			let depthTexture: MCTexture = try MCTexture.init(pixelBuffer: &newPixelBuffer, textureCache: textureCache, colorPixelFormat: MTLPixelFormat.bgra8Unorm, planeIndex: 0)
			let depthImage: CIImage = CIImage(cvPixelBuffer: depthPixelBuffer, options: [:])
			let depthCloppdImage: CIImage = depthImage.clampedToExtent().cropped(to: depthImage.extent)
			MCCore.ciContext.render(depthCloppdImage, to: depthTexture.texture, commandBuffer: commandBuffer, bounds: depthCloppdImage.extent, colorSpace: depthImage.colorSpace!)
			//////////////////////////////////////////////////////////
			
			//////////////////////////////////////////////////////////
			// outTexture canvas 生成
			var outTexture: MCTexture
			if self.texture == nil {
				guard var newImageBuffer: CVImageBuffer = CVImageBuffer.create(size: renderSize) else { return }
				outTexture = try MCTexture.init(pixelBuffer: &newImageBuffer, textureCache: textureCache, colorPixelFormat: MTLPixelFormat.bgra8Unorm, planeIndex: 0)
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
				mat.scale(x: Float(renderSize.width) / Float(depthTexture.height), y: Float(renderSize.height) / Float(depthTexture.width), z: 1.0)
				mat.rotateAroundX(xAngleRad: 0.0, yAngleRad: 0.0, zAngleRad: Float(angle))
				mat.translate(x: 0, y: -Float(depthTexture.height), z: 0.0)
				image = try MCPrimitive.Image.init(texture: depthTexture, ppsition: MCGeom.Vec3D.init(0.0, 0.0, 0.0), transform: mat, anchorPoint: MCPrimitive.anchor.topLeft)
				
				self.image = image
			} else {
				image = self.image!
			}
			image.texture = depthTexture
			try self.canvas?.draw(commandBuffer: &commandBuffer, objects: [
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

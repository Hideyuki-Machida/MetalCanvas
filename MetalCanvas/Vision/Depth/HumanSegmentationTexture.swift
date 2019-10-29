//
//  DepthMapToHumanSegmentationTexture.swift
//  iOS_AVModule
//
//  Created by hideyuki machida on 2019/01/16.
//  Copyright © 2019 町田 秀行. All rights reserved.
//

import Foundation
import AVFoundation

extension MCVision.Depth {
	public struct HumanSegmentationTexture {
		private var blurRadius: Float = 2.0
		private var gamma: Float = 1.5
		
		public fileprivate(set) var texture: MCTexture?
		fileprivate(set) var canvas: MCCanvas?
		fileprivate(set) var image: MCPrimitive.Image?
		
		public init () {}
		
		public mutating func update(to depthData: AVDepthData, metadataFaceObjects: [AVMetadataFaceObject], commandBuffer: inout MTLCommandBuffer, renderSize: CGSize) throws {
			let depthPixelBuffer: CVPixelBuffer = depthData.depthDataMap
			//depthPixelBuffer.normalize()
			//guard let depthData: AVDepthData = depthData else { throw Renderer.ErrorType.rendering }
			guard let faceObject: AVMetadataFaceObject = metadataFaceObjects.first else { throw MCVision.ErrorType.rendering }
			let depthWidth: Int = CVPixelBufferGetWidth(depthPixelBuffer)
			let depthHeight: Int = CVPixelBufferGetHeight(depthPixelBuffer)
			guard var newPixelBuffer: CVPixelBuffer = CVPixelBuffer.create(size: CGSize.init(width: depthWidth, height: depthHeight)) else { throw MCVision.ErrorType.rendering }
			let alphaMatteTexture: MCTexture = try MCTexture.init(pixelBuffer: &newPixelBuffer, planeIndex: 0)
			
			//depthPixelBuffer.normalize()
			let faceCenter: CGPoint = CGPoint(x: faceObject.bounds.midX, y: faceObject.bounds.midY)
			let scale: CGFloat = CGFloat(CVPixelBufferGetWidth(depthPixelBuffer)) / renderSize.width

			//let pixelX: Int = Int((faceCenter.y * scale).rounded())
			//let pixelY: Int = Int((faceCenter.x * scale).rounded())
			let pixelX: Int = Int(floor(faceCenter.y * scale))
			let pixelY: Int = Int(floor(faceCenter.x * scale))

			CVPixelBufferLockBaseAddress(depthPixelBuffer, .readOnly)
			guard let rawPointer: UnsafeMutableRawPointer = CVPixelBufferGetBaseAddress(depthPixelBuffer) else { CVPixelBufferUnlockBaseAddress(depthPixelBuffer, .readOnly); return }
			let rawPointer002: Int = CVPixelBufferGetBytesPerRow(depthPixelBuffer)
			let rowData: UnsafeMutableRawPointer = rawPointer + pixelY * rawPointer002
			let memoryBound: UnsafeMutablePointer<Float32> = rowData.assumingMemoryBound(to: Float32.self)
			let faceCenterDepth: Float32 = memoryBound[pixelX]
			CVPixelBufferUnlockBaseAddress(depthPixelBuffer, .readOnly)
			
			let depthCutOff = faceCenterDepth + 0.25
			//let depthCutOff = faceCenterDepth + 0.1
			
			CVPixelBufferLockBaseAddress(depthPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
			for yMap in 0 ..< depthHeight {
				let rowData = CVPixelBufferGetBaseAddress(depthPixelBuffer)! + yMap * CVPixelBufferGetBytesPerRow(depthPixelBuffer)
				let data = UnsafeMutableBufferPointer<Float32>(start: rowData.assumingMemoryBound(to: Float32.self), count: depthWidth)
				for index in 0 ..< depthWidth {
					if data[index] > 0 && data[index] <= depthCutOff {
						data[index] = 1.0
					} else {
						data[index] = 0.0
					}
				}
			}
			CVPixelBufferUnlockBaseAddress(depthPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
			
			// Create the mask from that pixel buffer.
			let depthImage: CIImage = CIImage(cvPixelBuffer: depthPixelBuffer, options: [:])
			let depthCloppdImage: CIImage = depthImage.clampedToExtent().cropped(to: depthImage.extent)
			MCCore.ciContext.render(depthCloppdImage, to: alphaMatteTexture.texture, commandBuffer: commandBuffer, bounds: depthCloppdImage.extent, colorSpace: depthImage.colorSpace!)
			
			//////////////////////////////////////////////////////////
			// outTexture canvas 生成
			var outTexture: MCTexture
			if self.texture == nil {
				guard var newImageBuffer: CVImageBuffer = CVImageBuffer.create(size: renderSize) else { return }
				outTexture = try MCTexture.init(pixelBuffer: &newImageBuffer, colorPixelFormat: MTLPixelFormat.bgra8Unorm, planeIndex: 0)
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
				mat.scale(x: Float(renderSize.width) / Float(alphaMatteTexture.height), y: Float(renderSize.height) / Float(alphaMatteTexture.width), z: 1.0)
				mat.rotateAroundX(xAngleRad: 0.0, yAngleRad: 0.0, zAngleRad: Float(angle))
				mat.translate(x: 0, y: -Float(alphaMatteTexture.height), z: 0.0)
				image = try MCPrimitive.Image.init(texture: alphaMatteTexture, ppsition:
                    SIMD3.init(0.0, 0.0, 0.0), transform: mat, anchorPoint: MCPrimitive.anchor.topLeft)
				
				self.image = image
			} else {
				image = self.image!
			}
			image.texture = alphaMatteTexture
			try self.canvas?.draw(commandBuffer: &commandBuffer, objects: [
				image,
				])
			//////////////////////////////////////////////////////////
			
			//////////////////////////////////////////////////////////
			// set
			//self.texture = outTexture
			self.texture = outTexture
			//////////////////////////////////////////////////////////
		}
	}
}

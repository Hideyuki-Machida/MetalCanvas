//
//  CVPixelBuffer+Extended.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/09.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation
import AVFoundation

extension CVPixelBuffer {
	
	static public func create(image: CGImage, pixelFormat: OSType = kCVPixelFormatType_32BGRA) -> CVPixelBuffer? {
		guard let pixelBuffer: CVPixelBuffer = create(size: CGSize.init(CGFloat(image.width), CGFloat(image.height)), pixelFormat: pixelFormat) else { return nil }
		
		CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
		
		let context = CGContext(
			data: CVPixelBufferGetBaseAddress(pixelBuffer),
			width: image.width,
			height: image.height,
			bitsPerComponent: image.bitsPerComponent,
			bytesPerRow: image.bytesPerRow,
			space: CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: image.bitmapInfo.rawValue)
		context?.draw(image, in: CGRect.init(CGFloat(image.width), CGFloat(image.height)))
		
		CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)

		return pixelBuffer
	}
}

extension CVPixelBuffer {
	
	static public func create(size: CGSize, pixelFormat: OSType = kCVPixelFormatType_32BGRA) -> CVPixelBuffer? {
		var pixelBuffer: CVPixelBuffer?
		
		let options = [
			kCVPixelBufferCGImageCompatibilityKey as String: true,
			kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
			kCVPixelBufferMetalCompatibilityKey as String: true,
			kCVPixelBufferOpenGLCompatibilityKey as String: true,
			kCVPixelBufferOpenGLESCompatibilityKey as String: true,
			//kCVPixelBufferOpenGLESTextureCacheCompatibilityKey as String: true
		]
		
		_ = CVPixelBufferCreate(kCFAllocatorDefault,
								Int(size.width),
								Int(size.height),
								pixelFormat,
								options as CFDictionary?,
								&pixelBuffer)
		
		return pixelBuffer
	}
}

extension CVPixelBuffer {
	public func normalize() {
		
		let width = CVPixelBufferGetWidth(self)
		let height = CVPixelBufferGetHeight(self)
		
		CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
		let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
		
		var minPixel: Float = 1.0
		var maxPixel: Float = 0.0
		
		for y in 0 ..< height {
			for x in 0 ..< width {
				let pixel = floatBuffer[y * width + x]
				minPixel = min(pixel, minPixel)
				maxPixel = max(pixel, maxPixel)
			}
		}
		
		let range = maxPixel - minPixel
		
		for y in 0 ..< height {
			for x in 0 ..< width {
				let pixel = floatBuffer[y * width + x]
				floatBuffer[y * width + x] = (pixel - minPixel) / range
			}
		}
		
		CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
	}
	
	public func printDebugInfo() {
		
		let width = CVPixelBufferGetWidth(self)
		let height = CVPixelBufferGetHeight(self)
		let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
		let totalBytes = CVPixelBufferGetDataSize(self)
		
		print("Depth Map Info: \(width)x\(height)")
		print(" Bytes per Row: \(bytesPerRow)")
		print("   Total Bytes: \(totalBytes)")
	}
	
	public func convertToDisparity32() -> CVPixelBuffer? {
		
		let width = CVPixelBufferGetWidth(self)
		let height = CVPixelBufferGetHeight(self)
		
		var dispartyPixelBuffer: CVPixelBuffer?
		
		let _ = CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_DisparityFloat32, nil, &dispartyPixelBuffer)
		
		guard let outputPixelBuffer = dispartyPixelBuffer else {
			return nil
		}
		
		CVPixelBufferLockBaseAddress(outputPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
		CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 1))
		
		let outputBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(outputPixelBuffer), to: UnsafeMutablePointer<Float>.self)
		let inputBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<UInt8>.self)
		
		for y in 0 ..< height {
			for x in 0 ..< width {
				let pixel = inputBuffer[y * width + x]
				outputBuffer[y * width + x] = (Float(pixel) / Float(UInt8.max))
			}
		}
		
		CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 1))
		CVPixelBufferUnlockBaseAddress(outputPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
		
		return dispartyPixelBuffer
	}
}

extension CVPixelBuffer {
	/// Deep copy a CVPixelBuffer:
	///   http://stackoverflow.com/questions/38335365/pulling-data-from-a-cmsamplebuffer-in-order-to-create-a-deep-copy
	public func copy() -> CVPixelBuffer
	{
		precondition(CFGetTypeID(self) == CVPixelBufferGetTypeID(), "copy() cannot be called on a non-CVPixelBuffer")
		
		var _copy: CVPixelBuffer?
		
		let options = [
			kCVPixelBufferCGImageCompatibilityKey as String: true,
			kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
			kCVPixelBufferMetalCompatibilityKey as String: true,
			kCVPixelBufferOpenGLCompatibilityKey as String: true,
			kCVPixelBufferOpenGLESCompatibilityKey as String: true,
			kCVPixelBufferOpenGLESTextureCacheCompatibilityKey as String: true
		]
		
		CVPixelBufferCreate(
			nil,
			CVPixelBufferGetWidth(self),
			CVPixelBufferGetHeight(self),
			CVPixelBufferGetPixelFormatType(self),
			options as CFDictionary?,
			//CVBufferPropagateAttachments(self, _copy ?? <#default value#>) as! CFDictionary,
			//CVBufferGetAttachments(self, .shouldPropagate),
			&_copy)
		
		guard let copy = _copy else { fatalError() }
		
		CVPixelBufferLockBaseAddress(self, .readOnly)
		CVPixelBufferLockBaseAddress(copy, [])
		
		for plane in 0 ..< CVPixelBufferGetPlaneCount(self)
		{
			let dest        = CVPixelBufferGetBaseAddressOfPlane(copy, plane)
			let source      = CVPixelBufferGetBaseAddressOfPlane(self, plane)
			let height      = CVPixelBufferGetHeightOfPlane(self, plane)
			let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(self, plane)
			
			memcpy(dest, source, height * bytesPerRow)
		}
		
		CVPixelBufferUnlockBaseAddress(copy, [])
		CVPixelBufferUnlockBaseAddress(self, .readOnly)
		
		return copy
	}
}

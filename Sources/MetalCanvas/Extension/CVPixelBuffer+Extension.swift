//
//  CVPixelBuffer+Extension.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/09.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import AVFoundation
import Foundation

extension CVPixelBuffer {
    public static func create(image: CGImage, pixelFormat: OSType = kCVPixelFormatType_32BGRA) -> CVPixelBuffer? {
        let size: MCSize = MCSize(Float(image.width), Float(image.height))
        guard let pixelBuffer: CVPixelBuffer = self.create(size: size, pixelFormat: pixelFormat) else { return nil }

        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: image.width,
            height: image.height,
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: image.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        context?.draw(image, in: CGRect(w: CGFloat(image.width), h: CGFloat(image.height)))

        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)

        return pixelBuffer
    }
}

extension CVPixelBuffer {
    public static func create(size: MCSize, pixelFormat: OSType = kCVPixelFormatType_32BGRA) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?

        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferMetalCompatibilityKey as String: true,
            kCVPixelBufferOpenGLCompatibilityKey as String: true,
        ]

        _ = CVPixelBufferCreate(kCFAllocatorDefault,
                                Int(size.w),
                                Int(size.h),
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
        let width: Int = CVPixelBufferGetWidth(self)
        let height: Int = CVPixelBufferGetHeight(self)
        let bytesPerRow: Int = CVPixelBufferGetBytesPerRow(self)
        let totalBytes: Int = CVPixelBufferGetDataSize(self)
        MCDebug.log("width: \(width)")
        MCDebug.log("height: \(height)")
        MCDebug.log("bytesPerRow: \(bytesPerRow)")
        MCDebug.log("totalBytes: \(totalBytes)")
    }

    public func convertToDisparity32() -> CVPixelBuffer? {
        let width: Int = CVPixelBufferGetWidth(self)
        let height: Int = CVPixelBufferGetHeight(self)

        var disparityPixelBuffer: CVPixelBuffer?

        _ = CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_DisparityFloat32, nil, &disparityPixelBuffer)

        guard let outputPixelBuffer = disparityPixelBuffer else {
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

        return disparityPixelBuffer
    }
}

extension CVPixelBuffer {
    /// Deep copy a CVPixelBuffer:
    ///   http://stackoverflow.com/questions/38335365/pulling-data-from-a-cmsamplebuffer-in-order-to-create-a-deep-copy
    public func copy() -> CVPixelBuffer {
        precondition(CFGetTypeID(self) == CVPixelBufferGetTypeID(), "copy() cannot be called on a non-CVPixelBuffer")

        // swiftlint:disable:next identifier_name
        var _copy: CVPixelBuffer?
        // swiftlint:disable:previous identifier_name

        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferMetalCompatibilityKey as String: true,
            kCVPixelBufferOpenGLCompatibilityKey as String: true,
        ]

        CVPixelBufferCreate(
            nil,
            CVPixelBufferGetWidth(self),
            CVPixelBufferGetHeight(self),
            CVPixelBufferGetPixelFormatType(self),
            options as CFDictionary?,
            &_copy
        )

        guard let copy = _copy else { fatalError() }

        CVPixelBufferLockBaseAddress(self, .readOnly)
        CVPixelBufferLockBaseAddress(copy, [])

        for plane in 0 ..< CVPixelBufferGetPlaneCount(self) {
            let dest = CVPixelBufferGetBaseAddressOfPlane(copy, plane)
            let source = CVPixelBufferGetBaseAddressOfPlane(self, plane)
            let height = CVPixelBufferGetHeightOfPlane(self, plane)
            let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(self, plane)

            memcpy(dest, source, height * bytesPerRow)
        }

        CVPixelBufferUnlockBaseAddress(copy, [])
        CVPixelBufferUnlockBaseAddress(self, .readOnly)

        return copy
    }
}

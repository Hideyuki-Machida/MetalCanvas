//
//  MCCore.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2018/12/29.
//  Copyright © 2018 hideyuki machida. All rights reserved.
//

import AVFoundation
import Foundation
import Metal
import MetalKit

public final class MCCore {
    public enum MCCoreErrorType: Error {
        case setup
        case createMetalRenderPassDescriptorError
        case createMetalBuffer
    }

    public fileprivate(set) static var isMetalCanvas: Bool = false

    public fileprivate(set) static var device: MTLDevice!
    public fileprivate(set) static var commandQueue: MTLCommandQueue!
    public fileprivate(set) static var ciContext: CIContext!
    public fileprivate(set) static var library: MTLLibrary!
    public fileprivate(set) static var textureLoader: MTKTextureLoader!
    public fileprivate(set) static var textureCache: CVMetalTextureCache?

    public static func setup(contextOptions: [CIContextOption: Any]) throws {
        let errorMessage: String = "MetalCanvas: SetupError"

        ///////////////////////////////////////////////////////////////////////////////
        // Metalの各ツール設定
        guard
            let device: MTLDevice = MTLCreateSystemDefaultDevice(),
            let commandQueue: MTLCommandQueue = device.makeCommandQueue()
        else {
            MCDebug.errorLog(errorMessage)
            self.isMetalCanvas = false
            throw MCCoreErrorType.setup
        }

        self.device = device
        self.commandQueue = commandQueue
        self.textureLoader = MTKTextureLoader(device: device)
        self.textureCache = MCCore.createTextureCache(device: MCCore.device)
        ///////////////////////////////////////////////////////////////////////////////

        ///////////////////////////////////////////////////////////////////////////////
        // default.metallib 取得
        let bundle: Bundle = MCTools.shared.bundle
        let path: String = bundle.bundlePath + "/default.metallib"
        do {
            self.library = try device.makeLibrary(filepath: path)
        } catch {
            MCDebug.errorLog(errorMessage)
            self.isMetalCanvas = false
            throw MCCoreErrorType.setup
        }
        ///////////////////////////////////////////////////////////////////////////////

        ///////////////////////////////////////////////////////////////////////////////
        // CIContext設定
        if !contextOptions.isEmpty {
            // コンテクストのオプションが指定されている
            self.ciContext = CIContext(mtlDevice: device, options: contextOptions)
        } else {
            // コンテクストのオプションが指定されていない
            self.ciContext = CIContext(
                mtlDevice: device, options: [
                    CIContextOption.workingColorSpace: CGColorSpaceCreateDeviceRGB(),
                    CIContextOption.useSoftwareRenderer: NSNumber(value: false),
                ]
            )
        }

        self.isMetalCanvas = true
        ///////////////////////////////////////////////////////////////////////////////
    }
}

extension MCCore {
    public static func createTextureCache() -> CVMetalTextureCache? {
        return self.createTextureCache(device: self.device)
    }

    private static func createTextureCache(device: MTLDevice) -> CVMetalTextureCache? {
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        return textureCache
    }
}

extension MCCore {
    public static func makeBuffer<T>(data: [T]) throws -> MTLBuffer {
        let length: Int = MemoryLayout<T>.size * data.count
        guard let buffer: MTLBuffer = MCCore.device.makeBuffer(bytes: data, length: length) else { throw MCCoreErrorType.createMetalBuffer }
        return buffer
    }
}

extension MCCore {
    public static func texture(sampleBuffer: inout CMSampleBuffer, textureCache: inout CVMetalTextureCache, colorPixelFormat: MTLPixelFormat) -> MTLTexture? {
        guard var pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        return MCCore.texture(pixelBuffer: &pixelBuffer, textureCache: &textureCache, colorPixelFormat: colorPixelFormat)
    }

    public static func texture(pixelBuffer: inout CVPixelBuffer, textureCache: inout CVMetalTextureCache, colorPixelFormat: MTLPixelFormat) -> MTLTexture? {
        let width: Int = CVPixelBufferGetWidth(pixelBuffer)
        let height: Int = CVPixelBufferGetHeight(pixelBuffer)
        var imageTexture: CVMetalTexture?
        let result: CVReturn = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer, nil, colorPixelFormat, width, height, 0, &imageTexture)
        guard result == kCVReturnSuccess else { return nil }
        guard let imgTexture: CVMetalTexture = imageTexture else { return nil }
        if let texture: MTLTexture = CVMetalTextureGetTexture(imgTexture) {
            return texture
        }
        return nil
    }

    public static func texture(sampleBuffer: inout CMSampleBuffer, colorPixelFormat: MTLPixelFormat, planeIndex: Int = 0) -> MTLTexture? {
        guard var pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        return MCCore.texture(pixelBuffer: &pixelBuffer, colorPixelFormat: colorPixelFormat, planeIndex: planeIndex)
    }

    public static func texture(pixelBuffer: inout CVPixelBuffer, colorPixelFormat: MTLPixelFormat, planeIndex: Int = 0) -> MTLTexture? {
        guard let textureCache: CVMetalTextureCache = MCCore.textureCache ?? MCCore.createTextureCache(device: MCCore.device) else { return nil }
        return MCCore.texture(pixelBuffer: &pixelBuffer, textureCache: textureCache, colorPixelFormat: colorPixelFormat, planeIndex: planeIndex)
    }

    public static func texture(pixelBuffer: inout CVPixelBuffer, textureCache: CVMetalTextureCache, colorPixelFormat: MTLPixelFormat, planeIndex: Int = 0) -> MTLTexture? {
        let width: Int = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height: Int = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)
        var imageTexture: CVMetalTexture?
        let result: CVReturn = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer, nil, colorPixelFormat, width, height, planeIndex, &imageTexture)
        guard result == kCVReturnSuccess else { return nil }
        guard let imgTexture: CVMetalTexture = imageTexture else { return nil }
        if let texture: MTLTexture = CVMetalTextureGetTexture(imgTexture) {
            return texture
        }
        return nil
    }

    public static func texture(cgImage: inout CGImage, colorPixelFormat: MTLPixelFormat) -> MTLTexture? {
        return try? self.textureLoader.newTexture(cgImage: cgImage, options: nil)
    }

    public static func texture(URL: URL, isSRGB: Bool = false) throws -> MTLTexture {
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
            MTKTextureLoader.Option.SRGB: isSRGB,
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.private.rawValue),
        ]
        return try MCCore.textureLoader.newTexture(URL: URL, options: textureLoaderOptions)
    }

    public static func flush() {
        MCCore.textureCache = MCCore.createTextureCache(device: MCCore.device)
        MCCore.ciContext.clearCaches()
    }
}

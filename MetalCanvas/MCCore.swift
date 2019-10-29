//
//  MCCore.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2018/12/29.
//  Copyright © 2018 hideyuki machida. All rights reserved.
//

import Foundation
import AVFoundation
import Metal
import MetalKit

final public class MCCore {
    
    public enum MCCoreErrorType: Error {
        case createMetalRenderPassDescriptorError
        case createMetalBuffer
    }

    public static var isMetalCanvas: Bool = (MTLCreateSystemDefaultDevice() == nil ? false : true)
        
    public static let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    public static let commandQueue: MTLCommandQueue = MCCore.device.makeCommandQueue()!
    public fileprivate(set) static var ciContext = CIContext(
        mtlDevice: MCCore.device, options: [
            CIContextOption.workingColorSpace : CGColorSpaceCreateDeviceRGB(),
            CIContextOption.useSoftwareRenderer : NSNumber(value: false)
        ])
    public fileprivate(set) static var library: MTLLibrary!

    public static var textureCache: CVMetalTextureCache? = MCCore.createTextureCache()
    public static var textureLoader: MTKTextureLoader = MTKTextureLoader(device: MCCore.device)
    
    public static func createTextureCache() -> CVMetalTextureCache? {
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MCCore.device, nil, &textureCache)
        return textureCache
    }
    
    public static func setup(contextPptions: [CIContextOption : Any]) throws {
        MCCore.ciContext = CIContext(mtlDevice: MCCore.device, options: contextPptions)
        let bundlr: Bundle = Bundle.init(identifier: "hideyuki.machida.MetalCanvas")!
        let path: String = bundlr.bundlePath + "/default.metallib"
        MCCore.library = try MCCore.device.makeLibrary(filepath: path)
    }
}

extension MCCore {
    public static func createMetalBuffer(vertexData: inout [Float]) throws -> MTLBuffer {
        guard let buffer: MTLBuffer = MCCore.device.makeBuffer(bytes: vertexData, length: MemoryLayout.size(ofValue: vertexData[0]) * vertexData.count, options: []) else { throw MCCoreErrorType.createMetalBuffer }
        return buffer
    }
    
    public static func makeBuffer<T>(data: [T]) throws -> MTLBuffer {
        let size: Int = data.count * MemoryLayout<T>.size
        guard let buffer: MTLBuffer = MCCore.device.makeBuffer(bytes: data, length: size, options: []) else { throw MCCoreErrorType.createMetalBuffer }
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
        } else {
            return nil
        }
    }
    
    public static func texture(sampleBuffer: inout CMSampleBuffer, colorPixelFormat: MTLPixelFormat, planeIndex: Int = 0) -> MTLTexture? {
        guard var pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        return MCCore.texture(pixelBuffer: &pixelBuffer, colorPixelFormat: colorPixelFormat, planeIndex: planeIndex)
    }
    
    public static func texture(pixelBuffer: inout CVPixelBuffer, colorPixelFormat: MTLPixelFormat, planeIndex: Int = 0) -> MTLTexture? {
        guard let textureCache: CVMetalTextureCache = MCCore.textureCache else { return nil }
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
        } else {
            return nil
        }
    }
    
    public static func texture(cgImage: inout CGImage, colorPixelFormat: MTLPixelFormat) -> MTLTexture? {
        return try? self.textureLoader.newTexture(cgImage: cgImage, options: nil)
    }

    public static func texture(URL: URL, isSRGB: Bool = false) throws -> MTLTexture {
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
            MTKTextureLoader.Option.SRGB: isSRGB,
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.private.rawValue)
        ]
        return try MCCore.textureLoader.newTexture(URL: URL, options: textureLoaderOptions)
    }

}

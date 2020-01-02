//
//  MCTexture.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/03.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation
import MetalKit

public struct MCTexture {
    public enum ErrorType: Error {
        case createError
    }

    public var width: Int { return texture.width }
    public var height: Int { return texture.height }
    fileprivate(set) public var size: SIMD2<Float>
    public var pixelFormat: MTLPixelFormat { return texture.pixelFormat }
    fileprivate(set) public var pixelBuffer: CVPixelBuffer?

    public private(set) var texture: MTLTexture
    public init(renderSize: CGSize) throws {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.bgra8Unorm, width: Int(renderSize.width), height: Int(renderSize.height), mipmapped: true)
        textureDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget, .pixelFormatView]
        guard let texture: MTLTexture = MCCore.device.makeTexture(descriptor: textureDescriptor) else { throw ErrorType.createError }
        try self.init(texture: texture)
    }

    public init(image: UIImage, isSRGB: Bool = false) throws {
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
            MTKTextureLoader.Option.SRGB: isSRGB,
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.private.rawValue),
        ]
        guard let cgImage = image.cgImage else { throw ErrorType.createError }
        let texture: MTLTexture = try MCCore.textureLoader.newTexture(cgImage: cgImage, options: textureLoaderOptions)
        try self.init(texture: texture)
    }

    public init(image: CGImage, isSRGB: Bool = false) throws {
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
            MTKTextureLoader.Option.SRGB: isSRGB,
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.private.rawValue),
        ]
        let texture: MTLTexture = try MCCore.textureLoader.newTexture(cgImage: image, options: textureLoaderOptions)
        try self.init(texture: texture)
    }

    public init(URL: URL, isSRGB: Bool = false) throws {
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
            MTKTextureLoader.Option.SRGB: isSRGB,
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.private.rawValue),
        ]
        let texture: MTLTexture = try MCCore.textureLoader.newTexture(URL: URL, options: textureLoaderOptions)
        try self.init(texture: texture)
    }

    public init(URL: URL, commandBuffer: MTLCommandBuffer) throws {
        guard
            let inputImage: CIImage = CIImage(contentsOf: URL),
            let colorSpace: CGColorSpace = inputImage.colorSpace
        else { throw ErrorType.createError }
        let renderSize: CGSize = inputImage.extent.size

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: MTLPixelFormat.bgra8Unorm,
            width: Int(renderSize.width), height: Int(renderSize.height),
            mipmapped: true
        )
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        guard let texture: MTLTexture = MCCore.device.makeTexture(descriptor: textureDescriptor) else { throw ErrorType.createError }
        MCCore.ciContext.render(inputImage, to: texture, commandBuffer: commandBuffer, bounds: inputImage.extent, colorSpace: colorSpace)
        try self.init(texture: texture)
    }

    public init(pixelBuffer: inout CVPixelBuffer, planeIndex: Int) throws {
        try self.init(pixelBuffer: &pixelBuffer, colorPixelFormat: MTLPixelFormat.bgra8Unorm, planeIndex: planeIndex)
    }

    public init(pixelBuffer: inout CVPixelBuffer, colorPixelFormat: MTLPixelFormat, planeIndex: Int) throws {
        guard let texture: MTLTexture = MCCore.texture(pixelBuffer: &pixelBuffer, colorPixelFormat: colorPixelFormat, planeIndex: planeIndex) else { throw ErrorType.createError }
        try self.init(texture: texture)
        self.pixelBuffer = pixelBuffer
    }

    public init(pixelBuffer: inout CVPixelBuffer, textureCache: CVMetalTextureCache, colorPixelFormat: MTLPixelFormat, planeIndex: Int) throws {
        guard let texture: MTLTexture = MCCore.texture(pixelBuffer: &pixelBuffer, textureCache: textureCache, colorPixelFormat: colorPixelFormat, planeIndex: planeIndex) else { throw ErrorType.createError }
        try self.init(texture: texture)
        self.pixelBuffer = pixelBuffer
    }

    public init(texture: MTLTexture) throws {
        self.texture = texture
        self.size = SIMD2<Float>(Float(texture.width), Float(texture.height))
    }

}

public extension MCTexture {
    func copy() throws -> MCTexture {
        guard let texture: MTLTexture = self.texture.makeTextureView(pixelFormat: self.pixelFormat) else { throw ErrorType.createError }
        return try MCTexture(texture: texture)
    }

    mutating func update(commandBuffer: MTLCommandBuffer, URL: URL) throws {
        guard let image: CIImage = CIImage(contentsOf: URL) else { throw ErrorType.createError }
        let colorSpace: CGColorSpace = image.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        MCCore.ciContext.render(image, to: self.texture, commandBuffer: commandBuffer, bounds: image.extent, colorSpace: colorSpace)
    }
}

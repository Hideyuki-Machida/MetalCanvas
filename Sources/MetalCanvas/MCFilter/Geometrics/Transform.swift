//
//  Transform.swift
//  
//
//  Created by hideyuki machida on 2020/10/04.
//

import Foundation
import GLKit
import Metal

extension MCFilter.Geometrics {
    public class Transform {
        // MARK: - vars
        ////////////////////////////////////////////////////////////////////
        // output
        public let outputPixelBuffer: CVPixelBuffer
        public let outputTexture: MTLTexture
        ////////////////////////////////////////////////////////////////////
        // pipeline
        private let pipelineState: MCRenderPipelineState
        private let vertexInBuffer: MTLBuffer
        private var renderPassDescriptor: MTLRenderPassDescriptor = MTLRenderPassDescriptor()

        // MatrixBuffer
        private let projectionMatrixBuffer: MTLBuffer

        public init(size: CGSize, orthoType: MCFilter.Geometrics.Transform.OrthoType) throws {
            self.pipelineState = try MCRenderPipelineState(
                vertex: MCFilter.Geometrics.Transform.shaderFunc.vertex,
                fragment: MCFilter.Geometrics.Transform.shaderFunc.fragment,
                label: "TransformFilter"
            )

            // projectionMatrix生成
            var projection: MCGeom.Matrix4x4 = MCGeom.Matrix4x4()
            projection.glkMatrix = orthoType.getMatrix(size: size)
            self.projectionMatrixBuffer = try MCCore.makeBuffer(data: projection.raw)

            // outputPixelBuffer & outputTexture生成
            var outputPixelBuffer: CVPixelBuffer = CVPixelBuffer.create(size: size)!
            self.outputPixelBuffer = outputPixelBuffer
            self.outputTexture = MCCore.texture(pixelBuffer: &outputPixelBuffer, mtlPixelFormat: MTLPixelFormat.bgra8Unorm)!

            self.vertexInBuffer = try MCCore.makeBuffer(data: MCShaderPreset.normalizedVertex)
            self.renderPassDescriptor.colorAttachments[0].texture = self.outputTexture
        }

        deinit {
            self.dispose()
        }

        public func dispose() {}

        public func process(commandBuffer: MTLCommandBuffer, transform: MCGeom.Matrix4x4 = MCGeom.Matrix4x4(), source: MTLTexture, anchorPoint: MCFilter.Geometrics.Transform.Anchor = .topLeft) throws {
            let imageMatrix: MCGeom.Matrix4x4 = anchorPoint.getMatrix(size: CGSize(w: CGFloat(source.width), h: CGFloat(source.height)))
            let objMatrix: MCGeom.Matrix4x4 = transform * imageMatrix
            let objMatrixBuffer: MTLBuffer = try MCCore.makeBuffer(data: objMatrix.raw)

            guard let renderCommandEncoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: self.renderPassDescriptor) else { throw MCFilter.ErrorType.drawError }
            renderCommandEncoder.setRenderPipelineState(self.pipelineState.renderPipelineState)
            renderCommandEncoder.setVertexBuffer(self.vertexInBuffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBuffer(self.projectionMatrixBuffer, offset: 0, index: 1)
            renderCommandEncoder.setVertexBuffer(objMatrixBuffer, offset: 0, index: 2)
            renderCommandEncoder.setFragmentTexture(source, index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            renderCommandEncoder.endEncoding()
        }
    }

}

extension MCFilter.Geometrics.Transform {
    // MARK: - MTLFunction

    private static let shaderFunc: ShaderFunc = MCFilter.Geometrics.Transform.ShaderFunc()

    fileprivate struct ShaderFunc {
        fileprivate let vertex: MTLFunction = MCCore.library.makeFunction(name: "vertex_Transform")!
        fileprivate let fragment: MTLFunction = MCCore.library.makeFunction(name: "fragment_Transform")!
    }
}

public extension MCFilter.Geometrics.Transform {
    enum OrthoType {
        case perspective
        case center
        case topLeft
        case bottomLeft

        func getMatrix(size: CGSize) -> GLKMatrix4 {
            switch self {
            case .perspective: return MCGeom.Matrix4x4().glkMatrix
            case .center: return GLKMatrix4MakeOrtho(-Float(size.width / 2), Float(size.width / 2), Float(size.height / 2), -Float(size.height / 2), -1, 1)
            case .topLeft: return GLKMatrix4MakeOrtho(0, Float(size.width), Float(size.height), 0, -1, 1)
            case .bottomLeft: return GLKMatrix4MakeOrtho(0, Float(size.width), 0, Float(size.height), -1, 1)
            }
        }
    }

    enum Anchor {
        case topLeft
        case bottomLeft
        case center

        func getMatrix(size: CGSize) -> MCGeom.Matrix4x4 {
            var matrix: MCGeom.Matrix4x4 = MCGeom.Matrix4x4()
            matrix.scale(x: Float(size.width) / 2.0, y: (Float(size.height) / 2.0) * -1, z: 0.0)

            switch self {
            case .topLeft: matrix.translate(x: 1, y: -1, z: 0.0)
            case .bottomLeft: matrix.translate(x: 1, y: 1, z: 0.0)
            case .center: matrix.translate(x: 0, y: 0, z: 0.0)
            }
            return matrix
        }
    }
}

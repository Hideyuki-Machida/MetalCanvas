//
//  MCMatrix4.swift
//  CameraCore
//
//  Created by hideyuki machida on 2018/12/24.
//  Copyright © 2018 町田 秀行. All rights reserved.
//

import Foundation
import GLKit

extension MCGeom {
    public struct Matrix4x4 {
        public var glkMatrix: GLKMatrix4 = GLKMatrix4Identity
        
        public init () {}
        public init (angleRad: Float, aspectRatio: Float, nearZ: Float, farZ: Float) {
            
            self.glkMatrix = GLKMatrix4MakePerspective(
                angleRad,
                aspectRatio,
                nearZ,
                farZ
            )
        }
    }
}

extension MCGeom.Matrix4x4 {
    public init (scaleX: Float, scaleY: Float, scaleZ: Float) {
        self.glkMatrix = GLKMatrix4Scale(self.glkMatrix, scaleX, scaleY, scaleZ)
    }
}


extension MCGeom.Matrix4x4 {
    public mutating func scale (x: Float, y: Float, z: Float) {
        glkMatrix = GLKMatrix4Scale(glkMatrix, x, y, z)
    }
    
    public mutating func rotateAroundX (xAngleRad: Float, yAngleRad: Float, zAngleRad: Float) {
        glkMatrix = GLKMatrix4Rotate(glkMatrix, xAngleRad, 1, 0, 0)
        glkMatrix = GLKMatrix4Rotate(glkMatrix, yAngleRad, 0, 1, 0)
        glkMatrix = GLKMatrix4Rotate(glkMatrix, zAngleRad, 0, 0, 1)
    }
    
    public mutating func translate (x: Float, y: Float, z: Float) {
        glkMatrix = GLKMatrix4Translate(glkMatrix, x, y, z)
    }
    
    public mutating func multiplyLeft (matrix: inout MCGeom.Matrix4x4) {
        glkMatrix = GLKMatrix4Multiply(matrix.glkMatrix, glkMatrix)
    }
    
    public mutating func transpose () {
        glkMatrix = GLKMatrix4Transpose(glkMatrix)
    }
    
    public func numberOfElements () -> Int {
        return 16
    }
}

extension MCGeom.Matrix4x4 {
    public static func + (left: MCGeom.Matrix4x4, right: MCGeom.Matrix4x4) -> MCGeom.Matrix4x4 {
        var mat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4.init()
        mat.glkMatrix = GLKMatrix4Add(left.glkMatrix, right.glkMatrix)
        return mat
    }

    public static func * (left: MCGeom.Matrix4x4, right: MCGeom.Matrix4x4) -> MCGeom.Matrix4x4 {
        var mat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4.init()
        mat.glkMatrix = GLKMatrix4Multiply(left.glkMatrix, right.glkMatrix)
        return mat
    }
}

extension MCGeom.Matrix4x4 {
    public func raw () -> [Float] {
        return [glkMatrix.m00, glkMatrix.m01, glkMatrix.m02, glkMatrix.m03, glkMatrix.m10, glkMatrix.m11, glkMatrix.m12, glkMatrix.m13, glkMatrix.m20, glkMatrix.m21, glkMatrix.m22, glkMatrix.m23, glkMatrix.m30, glkMatrix.m31, glkMatrix.m32, glkMatrix.m33]
    }
}

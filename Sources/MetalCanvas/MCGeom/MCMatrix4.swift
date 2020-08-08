//
//  MCMatrix4.swift
//  CameraCore
//
//  Created by hideyuki machida on 2018/12/24.
//  Copyright © 2018 hideyuki machida. All rights reserved.
//

import Foundation
import simd
import GLKit

extension MCGeom {
    public struct Matrix4x4 {
        public var glkMatrix: GLKMatrix4 = GLKMatrix4Identity

        public init() {}
        public init(angleRad: Float, aspectRatio: Float, nearZ: Float, farZ: Float) {
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
    public init(scaleX: Float, scaleY: Float, scaleZ: Float) {
        self.glkMatrix = GLKMatrix4Scale(self.glkMatrix, scaleX, scaleY, scaleZ)
    }
}

extension MCGeom.Matrix4x4 {
    public mutating func scale(x: Float, y: Float, z: Float) {
        glkMatrix = GLKMatrix4Scale(glkMatrix, x, y, z)
    }

    public mutating func rotateAroundX(xAngleRad: Float, yAngleRad: Float, zAngleRad: Float) {
        glkMatrix = GLKMatrix4Rotate(glkMatrix, xAngleRad, 1, 0, 0)
        glkMatrix = GLKMatrix4Rotate(glkMatrix, yAngleRad, 0, 1, 0)
        glkMatrix = GLKMatrix4Rotate(glkMatrix, zAngleRad, 0, 0, 1)
    }

    public mutating func translate(x: Float, y: Float, z: Float) {
        glkMatrix = GLKMatrix4Translate(glkMatrix, x, y, z)
    }

    public mutating func multiplyLeft(matrix: inout MCGeom.Matrix4x4) {
        glkMatrix = GLKMatrix4Multiply(matrix.glkMatrix, glkMatrix)
    }

    public mutating func transpose() {
        glkMatrix = GLKMatrix4Transpose(glkMatrix)
    }

    public func numberOfElements() -> Int {
        return 16
    }
}

extension MCGeom.Matrix4x4 {
    public static func + (left: MCGeom.Matrix4x4, right: MCGeom.Matrix4x4) -> MCGeom.Matrix4x4 {
        var mat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4()
        mat.glkMatrix = GLKMatrix4Add(left.glkMatrix, right.glkMatrix)
        return mat
    }

    public static func * (left: MCGeom.Matrix4x4, right: MCGeom.Matrix4x4) -> MCGeom.Matrix4x4 {
        var mat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4()
        mat.glkMatrix = GLKMatrix4Multiply(left.glkMatrix, right.glkMatrix)
        return mat
    }
}

extension MCGeom.Matrix4x4 {
    public var raw: [Float] {
        return [glkMatrix.m00, glkMatrix.m01, glkMatrix.m02, glkMatrix.m03,
                glkMatrix.m10, glkMatrix.m11, glkMatrix.m12, glkMatrix.m13,
                glkMatrix.m20, glkMatrix.m21, glkMatrix.m22, glkMatrix.m23,
                glkMatrix.m30, glkMatrix.m31, glkMatrix.m32, glkMatrix.m33]
    }
}

/*
extension MCGeom {
    public struct Matrix4x4 {
        private var m: simd_float4x4 = simd_float4x4(columns: (
            simd_float4.init(x: 1.0, y: 0.0, z: 0.0, w: 0.0),
            simd_float4.init(x: 0.0, y: 1.0, z: 0.0, w: 0.0),
            simd_float4.init(x: 0.0, y: 0.0, z: 1.0, w: 0.0),
            simd_float4.init(x: 0.0, y: 0.0, z: 0.0, w: 1.0))
        )

        public init() {}
        public init(_ float4x4: simd_float4x4) {
            self.m = float4x4
        }
        public init(angleRad: Float, aspectRatio: Float, nearZ: Float, farZ: Float) {
            let cotan: Float = 1.0 / tanf(angleRad / 2.0)
            self.m.columns = (
                SIMD4<Float>(cotan / aspectRatio, 0.0, 0.0, 0.0),
                SIMD4<Float>(0.0, cotan, 0.0, 0.0),
                SIMD4<Float>(0.0, 0.0, (farZ + nearZ) / (nearZ - farZ), -1.0),
                SIMD4<Float>(0.0, 0.0, (2.0 * farZ * nearZ) / (nearZ - farZ), 0.0)
            )
        }
    }

}

extension MCGeom.Matrix4x4 {
    public init(scaleX: Float, scaleY: Float, scaleZ: Float) {
        let m: (SIMD4<Float>, SIMD4<Float>, SIMD4<Float>, SIMD4<Float>) = self.m.columns
        self.m.columns = (
            SIMD4<Float>(m.0.x * scaleX, m.0.y * scaleX, m.0.z * scaleX, m.0.w * scaleX),
            SIMD4<Float>(m.1.x * scaleY, m.1.y * scaleY, m.1.z * scaleY, m.1.w * scaleY),
            SIMD4<Float>(m.2.x * scaleZ, m.2.y * scaleZ, m.2.z * scaleZ, m.2.w * scaleZ),
            SIMD4<Float>(m.3.x, m.3.y, m.3.z, m.3.w)
        )
    }
}

extension MCGeom.Matrix4x4 {
    public mutating func scale(x scaleX: Float, y scaleY: Float, z scaleZ: Float) {
        let m: (SIMD4<Float>, SIMD4<Float>, SIMD4<Float>, SIMD4<Float>) = self.m.columns
        self.m.columns = (
            SIMD4<Float>(m.0.x * scaleX, m.0.y * scaleX, m.0.z * scaleX, m.0.w * scaleX),
            SIMD4<Float>(m.1.x * scaleY, m.1.y * scaleY, m.1.z * scaleY, m.1.w * scaleY),
            SIMD4<Float>(m.2.x * scaleZ, m.2.y * scaleZ, m.2.z * scaleZ, m.2.w * scaleZ),
            SIMD4<Float>(m.3.x, m.3.y, m.3.z, m.3.w)
        )
    }

    /*
    public mutating func rotation(radians: Float, x: Float, y: Float, z: Float) {
        GLK_INLINE GLKMatrix4 GLKMatrix4MakeRotation(float radians, float x, float y, float z)
        {
            GLKVector3 v = GLKVector3Normalize(GLKVector3Make(x, y, z));
            float cos = cosf(radians);
            float cosp = 1.0f - cos;
            float sin = sinf(radians);
            
            GLKMatrix4 m = { cos + cosp * v.v[0] * v.v[0],
                             cosp * v.v[0] * v.v[1] + v.v[2] * sin,
                             cosp * v.v[0] * v.v[2] - v.v[1] * sin,
                             0.0f,
                             cosp * v.v[0] * v.v[1] - v.v[2] * sin,
                             cos + cosp * v.v[1] * v.v[1],
                             cosp * v.v[1] * v.v[2] + v.v[0] * sin,
                             0.0f,
                             cosp * v.v[0] * v.v[2] + v.v[1] * sin,
                             cosp * v.v[1] * v.v[2] - v.v[0] * sin,
                             cos + cosp * v.v[2] * v.v[2],
                             0.0f,
                             0.0f,
                             0.0f,
                             0.0f,
                             1.0f };

            return m;
        }

    }
     */
    
    public mutating func rotateX(radians: Float) {
        let cos: Float = cosf(radians);
        let sin: Float = sinf(radians);
        let mat: (SIMD4<Float>, SIMD4<Float>, SIMD4<Float>, SIMD4<Float>) = (
            SIMD4<Float>(1.0, 0.0, 0.0, 0.0),
            SIMD4<Float>(0.0, cos, sin, 0.0),
            SIMD4<Float>(0.0, -sin, cos, 0.0),
            SIMD4<Float>(0.0, 0.0, 0.0, 1.0)
        )
        let m: (SIMD4<Float>, SIMD4<Float>, SIMD4<Float>, SIMD4<Float>) = self.m.columns
    }

    public mutating func rotateY(radians: Float) {
        let cos: Float = cosf(radians);
        let sin: Float = sinf(radians);
        self.m.columns = (
            SIMD4<Float>(cos, 0.0, -sin, 0.0),
            SIMD4<Float>(0.0, 1.0, 0.0, 0.0),
            SIMD4<Float>(sin, 0.0, cos, 0.0),
            SIMD4<Float>(0.0, 0.0, 0.0, 1.0)
        )
    }

    public mutating func rotateZ(radians: Float) {
        let cos: Float = cosf(radians);
        let sin: Float = sinf(radians);
        self.m.columns = (
            SIMD4<Float>(cos, sin, 0.0, 0.0),
            SIMD4<Float>(-sin, cos, 0.0, 0.0),
            SIMD4<Float>(0.0, 0.0, 1.0, 0.0),
            SIMD4<Float>(0.0, 0.0, 0.0, 1.0)
        )
    }

    public mutating func translate(x tx: Float, y ty: Float, z tz: Float) {
        let m: (SIMD4<Float>, SIMD4<Float>, SIMD4<Float>, SIMD4<Float>) = self.m.columns
        self.m.columns = (
            SIMD4<Float>(m.0.x, m.0.y, m.0.z, m.0.w),
            SIMD4<Float>(m.1.x, m.1.y, m.1.z, m.1.w),
            SIMD4<Float>(m.2.x, m.2.y, m.2.z, m.2.w),
            SIMD4<Float>(
                m.0.x * tx + m.1.x * ty + m.2.x * tz + m.3.x,
                m.0.y * tx + m.1.y * ty + m.2.y * tz + m.3.y,
                m.0.z * tx + m.1.z * ty + m.2.z * tz + m.3.z,
                m.0.w * tx + m.1.w * ty + m.2.w * tz + m.3.w
            )
        )
    }


    public mutating func multiply(_ matrixLeft: MCGeom.Matrix4x4, _ matrixRight: MCGeom.Matrix4x4) {
        var m: (SIMD4<Float>, SIMD4<Float>, SIMD4<Float>, SIMD4<Float>) = self.m.columns
        let matrixLeft = matrixLeft.m.columns
        let matrixRight = matrixRight.m.columns


        //self.m.columns.0.x = matrixLeft.m.0.x * matrixRight.m.0.x  + matrixLeft.m.1.x * matrixRight.m.1  + matrixLeft.m.2.x * matrixRight.m.0.z   + matrixLeft.m.3.x * matrixRight.m.0.w
/*
        m.columns.0.x = matrixLeft.0.x * matrixRight.0.x + matrixLeft.1.x * matrixRight.0.y + matrixLeft.2.x * matrixRight.0.z + matrixLeft.3.x * matrixRight.0.w
        m.columns.1.x = matrixLeft.0.x * matrixRight.1.x + matrixLeft.1.x * matrixRight.1.y + matrixLeft.2.x * matrixRight.1.z + matrixLeft.3.x * matrixRight.1.w
        m.columns.2.x = matrixLeft.0.x * matrixRight.2.x + matrixLeft.1.x * matrixRight.2.y + matrixLeft.2.x * matrixRight.2.z + matrixLeft.3.x * matrixRight.2.w
        m.columns.3.x = matrixLeft.0.x * matrixRight.3.x + matrixLeft.1.x * matrixRight.3.y + matrixLeft.2.x * matrixRight.3.z + matrixLeft.3.x * matrixRight.3.w
        
        m.columns.0.y = matrixLeft.0.y * matrixRight.0.x  + matrixLeft.1.y * matrixRight.0.y + matrixLeft.2.y * matrixRight.0.z + matrixLeft.3.y * matrixRight.0.w;
        m.columns.1.y = matrixLeft.0.y * matrixRight.1.x  + matrixLeft.1.y * matrixRight.1.y  + matrixLeft.2.y * matrixRight.1.z   + matrixLeft.3.y * matrixRight.1.w;
        m.columns.2.y = matrixLeft.0.y * matrixRight.2.x  + matrixLeft.1.y * matrixRight.2.y  + matrixLeft.2.y * matrixRight.2.z  + matrixLeft.3.y * matrixRight.2.w;
        m.columns.3.y = matrixLeft.0.y * matrixRight.3.x + matrixLeft.1.y * matrixRight.3.y + matrixLeft.2.y * matrixRight.3.z  + matrixLeft.3.y * matrixRight.3.w;
        
        m.columns.0.z = matrixLeft.0.z * matrixRight.0.x  + matrixLeft.1.z * matrixRight.0.y  + matrixLeft.2.z * matrixRight.0.z  + matrixLeft.3.z * matrixRight.0.w;
        m.columns.1.z = matrixLeft.0.z * matrixRight.1.x  + matrixLeft.1.z * matrixRight.1.y  + matrixLeft.2.z * matrixRight.1.z  + matrixLeft.3.z * matrixRight.1.w;
        m.columns.2.z = matrixLeft.0.z * matrixRight.2.x  + matrixLeft.1.z * matrixRight.2.y  + matrixLeft.2.z * matrixRight.2.z + matrixLeft.3.z * matrixRight.2.w;
        m.columns.3.z = matrixLeft.0.z * matrixRight.3.x + matrixLeft.1.z * matrixRight.3.y + matrixLeft.2.z * matrixRight.3.z + matrixLeft.3.z * matrixRight.3.w;
        
        m.columns.0.w = matrixLeft.0.w * matrixRight.0.x  + matrixLeft.1.w * matrixRight.0.y  + matrixLeft.2.w * matrixRight.0.z  + matrixLeft.3.w * matrixRight.0.w;
        m.columns.1.w = matrixLeft.0.w * matrixRight.1.x  + matrixLeft.1.w * matrixRight.1.y  + matrixLeft.2.w * matrixRight.1.z  + matrixLeft.3.w * matrixRight.1.w;
        m.columns.2.w = matrixLeft.0.w * matrixRight.2.x  + matrixLeft.1.w * matrixRight.2.y  + matrixLeft.2.w * matrixRight.2.z + matrixLeft.3.w * matrixRight.2.w;
        m.columns.3.w = matrixLeft.0.w * matrixRight.3.x + matrixLeft.1.w * matrixRight.3.y + matrixLeft.2.w * matrixRight.3.z + matrixLeft.3.w * matrixRight.3.w;
 */

    }

    /*
    public mutating func transpose() {
        glkMatrix = GLKMatrix4Transpose(glkMatrix)
    }
*/
    public func numberOfElements() -> Int {
        return 16
    }
}


extension MCGeom.Matrix4x4 {
    /*
    public static func + (left: MCGeom.Matrix4x4, right: MCGeom.Matrix4x4) -> MCGeom.Matrix4x4 {
        var mat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4()
        mat.glkMatrix = GLKMatrix4Add(left.glkMatrix, right.glkMatrix)
        return mat
    }
*/

    
    public static func * (left: MCGeom.Matrix4x4, right: MCGeom.Matrix4x4) -> MCGeom.Matrix4x4 {
        var mat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4()
        let matrixLeft = left.m.columns
        let matrixRight = right.m.columns

        mat.m.columns.0.x = matrixLeft.0.x * matrixRight.0.x + matrixLeft.1.x * matrixRight.0.y + matrixLeft.2.x * matrixRight.0.z + matrixLeft.3.x * matrixRight.0.w
        mat.m.columns.1.x = matrixLeft.0.x * matrixRight.1.x + matrixLeft.1.x * matrixRight.1.y + matrixLeft.2.x * matrixRight.1.z + matrixLeft.3.x * matrixRight.1.w
        mat.m.columns.2.x = matrixLeft.0.x * matrixRight.2.x + matrixLeft.1.x * matrixRight.2.y + matrixLeft.2.x * matrixRight.2.z + matrixLeft.3.x * matrixRight.2.w
        mat.m.columns.3.x = matrixLeft.0.x * matrixRight.3.x + matrixLeft.1.x * matrixRight.3.y + matrixLeft.2.x * matrixRight.3.z + matrixLeft.3.x * matrixRight.3.w
        
        mat.m.columns.0.y = matrixLeft.0.y * matrixRight.0.x  + matrixLeft.1.y * matrixRight.0.y  + matrixLeft.2.y * matrixRight.0.z   + matrixLeft.3.y * matrixRight.0.w
        mat.m.columns.1.y = matrixLeft.0.y * matrixRight.1.x  + matrixLeft.1.y * matrixRight.1.y  + matrixLeft.2.y * matrixRight.1.z   + matrixLeft.3.y * matrixRight.1.w
        mat.m.columns.2.y = matrixLeft.0.y * matrixRight.2.x  + matrixLeft.1.y * matrixRight.2.y  + matrixLeft.2.y * matrixRight.2.z  + matrixLeft.3.y * matrixRight.2.w
        mat.m.columns.3.y = matrixLeft.0.y * matrixRight.3.x + matrixLeft.1.y * matrixRight.3.y + matrixLeft.2.y * matrixRight.3.z  + matrixLeft.3.y * matrixRight.3.w
        
        mat.m.columns.0.z = matrixLeft.0.z * matrixRight.0.x  + matrixLeft.1.z * matrixRight.0.y  + matrixLeft.2.z * matrixRight.0.z  + matrixLeft.3.z * matrixRight.0.w
        mat.m.columns.1.z = matrixLeft.0.z * matrixRight.1.x  + matrixLeft.1.z * matrixRight.1.y  + matrixLeft.2.z * matrixRight.1.z  + matrixLeft.3.z * matrixRight.1.w
        mat.m.columns.2.z = matrixLeft.0.z * matrixRight.2.x  + matrixLeft.1.z * matrixRight.2.y  + matrixLeft.2.z * matrixRight.2.z + matrixLeft.3.z * matrixRight.2.w
        mat.m.columns.3.z = matrixLeft.0.z * matrixRight.3.x + matrixLeft.1.z * matrixRight.3.y + matrixLeft.2.z * matrixRight.3.z + matrixLeft.3.z * matrixRight.3.w
        
        mat.m.columns.0.w = matrixLeft.0.w * matrixRight.0.x  + matrixLeft.1.w * matrixRight.0.y  + matrixLeft.2.w * matrixRight.0.z  + matrixLeft.3.w * matrixRight.0.w
        mat.m.columns.1.w = matrixLeft.0.w * matrixRight.1.x  + matrixLeft.1.w * matrixRight.1.y  + matrixLeft.2.w * matrixRight.1.z  + matrixLeft.3.w * matrixRight.1.w
        mat.m.columns.2.w = matrixLeft.0.w * matrixRight.2.x  + matrixLeft.1.w * matrixRight.2.y  + matrixLeft.2.w * matrixRight.2.z + matrixLeft.3.w * matrixRight.2.w
        mat.m.columns.3.w = matrixLeft.0.w * matrixRight.3.x + matrixLeft.1.w * matrixRight.3.y + matrixLeft.2.w * matrixRight.3.z + matrixLeft.3.w * matrixRight.3.w

        return mat
    }

}

/*
extension MCGeom.Matrix4x4 {
    public var raw: simd_float4x4 {
        return self.m
    }
}
*/
extension MCGeom.Matrix4x4 {
    public var raw: [Float] {
        let m: (SIMD4<Float>, SIMD4<Float>, SIMD4<Float>, SIMD4<Float>) = self.m.columns
        return [m.0.x, m.0.y, m.0.z, m.0.w,
                m.1.x, m.1.y, m.1.z, m.1.w,
                m.2.x, m.2.y, m.2.z, m.2.w,
                m.3.x, m.3.y, m.3.z, m.3.w
        ]
    }
}


extension MCGeom.Matrix4x4 {
    public static func Ortho(left: Float, right: Float, bottom: Float, top: Float, nearZ: Float, farZ: Float) -> MCGeom.Matrix4x4 {
        var m: simd_float4x4 = simd_float4x4()

        let ral: Float = right + left
        let rsl: Float = right - left
        let tab: Float = top + bottom
        let tsb: Float = top - bottom
        let fan: Float = farZ + nearZ
        let fsn: Float = farZ - nearZ

        m.columns = (
            SIMD4<Float>(2.0 / rsl, 0.0, 0.0, 0.0),
            SIMD4<Float>(0.0, 2.0 / tsb, 0.0, 0.0),
            SIMD4<Float>(0.0, 0.0, -2.0 / fsn, 0.0),
            SIMD4<Float>(-ral / rsl, -tab / tsb, -fan / fsn, 1.0)
        )
        
        return MCGeom.Matrix4x4.init(m)
    }
}
*/

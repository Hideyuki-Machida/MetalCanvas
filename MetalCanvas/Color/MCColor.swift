//
//  MCColor.swift
//  CameraCore
//
//  Created by hideyuki machida on 2018/12/25.
//  Copyright © 2018 町田 秀行. All rights reserved.
//

import Foundation

public typealias RGB = (r: Int, g: Int, b: Int)
public typealias RGBA = (r: Int, g: Int, b: Int, a: Int)
public typealias HSV = (h: Int, s: Int, v: Int)
public typealias HSVA = (h: Int, s: Int, v: Int, a: Int)

public struct MCColor {
    
    var color: SIMD4<Float> = [1.0, 1.0, 1.0, 1.0]
    
    public init(r: Float, g: Float, b: Float, a: Float) {
        self.color = [r, g, b, a]
    }
    
    public init(hex: String, alpha: Float = 1.0) {
        let hex: String = hex.replacingOccurrences(of: "#", with: "")
        let scanner: Scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r: UInt64 = (rgbValue & 0xff0000) >> 16
        let g: UInt64 = (rgbValue & 0xff00) >> 8
        let b: UInt64 = rgbValue & 0xff
        
        self.color = SIMD4<Float>.init(x: Float(r) / 0xff, y: Float(g) / 0xff, z: Float(b) / 0xff, w: alpha)
    }
}

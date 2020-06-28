//
//  Typealias.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2020/01/02.
//  Copyright © 2020 hideyuki machida. All rights reserved.
//

import Foundation
import CoreGraphics
import MetalCanvasShaders

public typealias MCSize = SIMD2<Float>
public typealias MCPoint = SIMD2<Float>

public extension MCSize {
    var w: Float { return self.x }
    var h: Float { return self.y }

    init(w: CGFloat, h: CGFloat) {
        self.init(Float(w), Float(h))
    }

    init(w: Int, h: Int) {
        self.init(Float(w), Float(h))
    }

    init(w: Float, h: Float) {
        self.init(w, h)
    }

    func toCGSize() -> CGSize {
        return CGSize.init(CGFloat(self.x), CGFloat(self.y))
    }
}
/*
public extension MCPoint {
    func toCGPoint() -> CGPoint {
        return CGPoint.init(CGFloat(self.x), CGFloat(self.y))
    }
}
*/

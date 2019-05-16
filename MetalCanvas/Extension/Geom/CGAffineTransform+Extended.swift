//
//  CGAffineTransform+Extention.swift
//  iOSGraphicsLibs
//
//  Created by hideyuki machida on 2018/07/16.
//  Copyright © 2018年 hideyuki machida. All rights reserved.
//

import UIKit

public extension CGAffineTransform {
    var radian: CGFloat {
        get {
            return atan2(self.b, self.a)
        }
    }

    var degree: CGFloat {
        get {
            return self.radian / CGFloat(Double.pi / 180)
        }
    }
    
    var scale: CGFloat {
        get {
            return sqrt(abs(self.a * self.d - self.b * self.c))
        }
    }
    
    var point: CGPoint {
        get {
            return CGPoint(x: self.tx, y: self.ty)
        }
        set {
            self.tx = newValue.x
            self.ty = newValue.y
        }
    }
}

public extension CGAffineTransform {
    var isPortrait: Bool {
        return (self.a == 0 && self.d == 0 && (self.b == 1.0 || self.b == -1.0) && (self.c == 1.0 || self.c == -1.0))
    }
    
    var isRotate: UIInterfaceOrientation {
        let degree: Int = Int(Double(atan2(self.b, self.a)) * 180.0 / Double.pi)
        switch degree {
        case 0:
            return .landscapeRight
        case 90:
            return .portrait
        case 180:
            return .landscapeLeft
        case -90:
            return .portraitUpsideDown
        default:
            return .unknown
        }
    }
}

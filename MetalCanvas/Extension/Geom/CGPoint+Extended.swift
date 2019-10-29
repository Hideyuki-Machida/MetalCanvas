//
//  CGPoint+Extended.swift
//  iOSGraphicsLibs
//
//  Created by hideyuki machida on 2018/07/29.
//  Copyright © 2018 hideyuki machida. All rights reserved.
//

import CoreGraphics

// MARK: - initialize

public extension CGPoint {
    init(_ x: CGFloat, _ y: CGFloat) {
        self = CGPoint.init(x: x, y: y)
    }
}


// MARK: - Basic operator - 演算子

public extension CGPoint {
    static func + (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x + right, y: left.y + right)
    }
    
    static func - (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x - right, y: left.y - right)
    }
    
    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }
    
    static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x / right, y: left.y / right)
    }
}

public extension CGPoint {
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func * (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x * right.x, y: left.y * right.y)
    }
    
    static func / (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x / right.x, y: left.y / right.y)
    }
}


// MARK: - Prefix operator - 前置演算子

public extension CGPoint {
    static prefix func + (left: CGPoint) -> CGPoint {
        return CGPoint(x: +left.x, y: +left.y)
    }
    
    static prefix func - (left: CGPoint) -> CGPoint {
        return CGPoint(x: -left.x, y: -left.y)
    }
}


// MARK: - Compound assignment operator - 複合代入演算子

public extension CGPoint {
    static func += (left: inout CGPoint, right: CGFloat) {
        left = left + right
    }
    
    static func -= (left: inout CGPoint, right: CGFloat) {
        left = left - right
    }
    
    static func *= (left: inout CGPoint, right: CGFloat) {
        left = left * right
    }
    
    static func /= (left: inout CGPoint, right: CGFloat) {
        left = left / right
    }
}

public extension CGPoint {
    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }
    
    static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }
    
    static func *= (left: inout CGPoint, right: CGPoint) {
        left = left * right
    }
    
    static func /= (left: inout CGPoint, right: CGPoint) {
        left = left / right
    }
}


// MARK: - Equality operator - 等価演算子

public extension CGPoint {
    static func != (left: CGPoint, right: CGPoint) -> Bool {
        return !(left == right)
    }
}


// MARK: - Utils

public extension CGPoint {
    func distance(point: CGPoint) -> CGFloat {
        return CGPoint.distance(point1: self, point2: point)
    }
    
    static func distance(point1: CGPoint, point2: CGPoint) -> CGFloat {
        let xDist: CGFloat = point2.x - point1.x
        let yDist: CGFloat = point2.y - point1.y
        return sqrt((xDist * xDist) + (yDist * yDist))
    }
}


// MARK: - Convert

public extension CGPoint {
    /*
    public func toCGPoint() -> CGPoint {
        return CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))
    }
    public func toCGSize() -> CGSize {
        return CGSize(width: CGFloat(self.x), height: CGFloat(self.y))
    }
 */
}

public extension CGPoint {
    func normalized(size: CGSize) -> CGPoint {
        return CGPoint.init(
            x: self.x / size.width,
            y: self.y / size.height
        )
    }
}

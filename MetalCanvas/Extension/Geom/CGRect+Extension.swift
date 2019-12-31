//
//  CGRect+Extension.swift
//  iOSGraphicsLibs
//
//  Created by hideyuki machida on 2018/07/29.
//  Copyright © 2018 Donuts. All rights reserved.
//

import CoreGraphics

public extension CGRect {
    init(size: CGSize) {
        self = CGRect(origin: CGPoint.zero, size: size)
    }

    init(w: CGFloat, h: CGFloat) {
        self = CGRect(origin: CGPoint.zero, size: CGSize(width: w, height: h))
    }

    var center: CGPoint {
        get {
            return CGPoint(x: self.midX, y: self.midY)
        }
        set {
            self.origin = CGPoint(x: newValue.x - (self.size.width / 2), y: newValue.y - (self.size.height / 2))
        }
    }

    func center(to: CGRect) -> CGRect {
        var rect = self
        rect.origin.x = (to.size.width / 2) - (rect.size.width / 2) + to.origin.x
        rect.origin.y = (to.size.height / 2) - (rect.size.height / 2) + to.origin.y
        return rect
    }

    func center(to: CGSize) -> CGRect {
        var rect = self
        rect.origin.x = (to.width / 2) - (rect.size.width / 2)
        rect.origin.y = (to.height / 2) - (rect.size.height / 2)
        return rect
    }

    var topLeft: CGPoint {
        get {
            return self.origin
        }
        set {
            self.origin = newValue
        }
    }

    var topRight: CGPoint {
        get {
            return CGPoint(x: self.origin.x + self.size.width, y: self.origin.y)
        }
        set {
            self.origin.x = newValue.x - self.size.width
        }
    }

    var bottomLeft: CGPoint {
        get {
            return CGPoint(x: self.origin.x, y: self.origin.y + self.size.height)
        }
        set {
            self.origin.x = newValue.x
            self.origin.y = newValue.y - self.size.height
        }
    }

    var bottomRight: CGPoint {
        get {
            return CGPoint(x: self.origin.x + self.size.width, y: self.origin.y + self.size.height)
        }
        set {
            self.origin.x = newValue.x - self.size.width
            self.origin.y = newValue.y - self.size.height
        }
    }

    var top: CGFloat {
        get {
            return self.origin.y
        }
        set(y) {
            self.origin.y = y
        }
    }

    var left: CGFloat {
        get {
            return self.origin.x
        }
        set(x) {
            self.origin.x = x
        }
    }

    var bottom: CGFloat {
        get {
            return self.origin.y + self.size.height
        }
        set(y) {
            self.origin.y = y - self.size.height
        }
    }

    var right: CGFloat {
        get {
            return self.origin.x + self.size.width
        }
        set(x) {
            self.origin.x = x - self.size.width
        }
    }
}

// MARK: - Basic operator - 演算子

public extension CGRect {
    static func + (left: CGRect, right: CGFloat) -> CGRect {
        return CGRect(origin: left.origin + right, size: left.size + right)
    }

    static func - (left: CGRect, right: CGFloat) -> CGRect {
        return CGRect(origin: left.origin - right, size: left.size - right)
    }

    static func * (left: CGRect, right: CGFloat) -> CGRect {
        return CGRect(origin: left.origin * right, size: left.size * right)
    }

    static func / (left: CGRect, right: CGFloat) -> CGRect {
        return CGRect(origin: left.origin / right, size: left.size / right)
    }
}

public extension CGRect {
    static func + (left: CGRect, right: CGRect) -> CGRect {
        return CGRect(origin: left.origin + right.origin, size: left.size + right.size)
    }

    static func - (left: CGRect, right: CGRect) -> CGRect {
        return CGRect(origin: left.origin - right.origin, size: left.size - right.size)
    }

    static func * (left: CGRect, right: CGRect) -> CGRect {
        return CGRect(origin: left.origin * right.origin, size: left.size * right.size)
    }

    static func / (left: CGRect, right: CGRect) -> CGRect {
        return CGRect(origin: left.origin / right.origin, size: left.size / right.size)
    }
}

public extension CGRect {
    func normalized(size: CGSize) -> CGRect {
        return CGRect(
            origin: self.origin.normalized(size: size),
            size: self.size.normalized(size: size)
        )
    }
}

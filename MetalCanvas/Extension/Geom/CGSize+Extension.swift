//
//  CGSize+Extension.swift
//  iOSGraphicsLibs
//
//  Created by hideyuki machida on 2018/07/29.
//  Copyright © 2018 Donuts. All rights reserved.
//

import CoreGraphics

public extension CGSize {
    init(w: CGFloat, h: CGFloat) {
        self = CGSize(width: w, height: h)
    }

    init(_ w: CGFloat, _ h: CGFloat) {
        self = CGSize(width: w, height: h)
    }
}

public extension CGSize {
    static func + (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width + right, height: left.height + right)
    }

    static func - (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width - right, height: left.height - right)
    }

    static func * (point: CGSize, scalar: CGFloat) -> CGSize {
        return CGSize(width: point.width * scalar, height: point.height * scalar)
    }

    static func / (point: CGSize, scalar: CGFloat) -> CGSize {
        return CGSize(width: point.width / scalar, height: point.height / scalar)
    }
}

public extension CGSize {
    static func + (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width + right.width, height: left.height + right.height)
    }

    static func - (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width - right.width, height: left.height - right.height)
    }

    static func * (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width * right.width, height: left.height * right.height)
    }

    static func / (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width / right.width, height: left.height / right.height)
    }
}

public extension CGSize {
    func normalized(size: CGSize) -> CGSize {
        return CGSize(
            width: self.width / size.width,
            height: self.height / size.height
        )
    }
}

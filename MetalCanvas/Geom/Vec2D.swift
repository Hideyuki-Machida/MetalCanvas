//
//  Vec2D.swift
//  iOS_AVModule
//
//  Created by hideyuki machida on 2018/12/24.
//  Copyright © 2018 町田 秀行. All rights reserved.
//

import Foundation

extension MCGeom {
	public struct Vec2D {
		public var x: Float
		public var y: Float
		
		public init(x: Float = 0.0, y: Float = 0.0) {
			self.x = x
			self.y = y
		}
	}
}

// MARK: - initialize

public extension MCGeom.Vec2D {
	init() {
		self.x = 0.0
		self.y = 0.0
	}
	
	init(_ x: Float, _ y: Float) {
		self.x = x
		self.y = y
	}
}


// MARK: - CustomPlaygroundDisplayConvertible

extension MCGeom.Vec2D: CustomPlaygroundDisplayConvertible {
	public var playgroundDescription: Any {
		return (x: self.x, y: self.y)
		//return "Vec2D(x: \(self.x), y: \(self.y))"
	}
}


// MARK: - Basic operator - 演算子

extension MCGeom.Vec2D {
	public static func + (left: MCGeom.Vec2D, right: Float) -> MCGeom.Vec2D {
		return MCGeom.Vec2D(x: left.x + right, y: left.y + right)
	}
	
	public static func - (left: MCGeom.Vec2D, right: Float) -> MCGeom.Vec2D {
		return MCGeom.Vec2D(x: left.x - right, y: left.y - right)
	}
	
	public static func * (left: MCGeom.Vec2D, right: Float) -> MCGeom.Vec2D {
		return MCGeom.Vec2D(x: left.x * right, y: left.y * right)
	}
	
	public static func / (left: MCGeom.Vec2D, right: Float) -> MCGeom.Vec2D {
		return MCGeom.Vec2D(x: left.x / right, y: left.y / right)
	}
}

extension MCGeom.Vec2D {
	public static func + (left: MCGeom.Vec2D, right: MCGeom.Vec2D) -> MCGeom.Vec2D {
		return MCGeom.Vec2D(x: left.x + right.x, y: left.y + right.y)
	}
	
	public static func - (left: MCGeom.Vec2D, right: MCGeom.Vec2D) -> MCGeom.Vec2D {
		return MCGeom.Vec2D(x: left.x - right.x, y: left.y - right.y)
	}
	
	public static func * (left: MCGeom.Vec2D, right: MCGeom.Vec2D) -> MCGeom.Vec2D {
		return MCGeom.Vec2D(x: left.x * right.x, y: left.y * right.y)
	}
	
	public static func / (left: MCGeom.Vec2D, right: MCGeom.Vec2D) -> MCGeom.Vec2D {
		return MCGeom.Vec2D(x: left.x / right.x, y: left.y / right.y)
	}
}


// MARK: - Prefix operator - 前置演算子

extension MCGeom.Vec2D {
	public static prefix func + (left: MCGeom.Vec2D) -> MCGeom.Vec2D {
		return MCGeom.Vec2D(x: +left.x, y: +left.y)
	}
	
	public static prefix func - (left: MCGeom.Vec2D) -> MCGeom.Vec2D {
		return MCGeom.Vec2D(x: -left.x, y: -left.y)
	}
}


// MARK: - Compound assignment operator - 複合代入演算子

extension MCGeom.Vec2D {
	public static func += (left: inout MCGeom.Vec2D, right: Float) {
		left = left + right
	}
	
	public static func -= (left: inout MCGeom.Vec2D, right: Float) {
		left = left - right
	}
	
	public static func *= (left: inout MCGeom.Vec2D, right: Float) {
		left = left * right
	}
	
	public static func /= (left: inout MCGeom.Vec2D, right: Float) {
		left = left / right
	}
}

extension MCGeom.Vec2D {
	public static func += (left: inout MCGeom.Vec2D, right: MCGeom.Vec2D) {
		left = left + right
	}
	
	public static func -= (left: inout MCGeom.Vec2D, right: MCGeom.Vec2D) {
		left = left - right
	}
	
	public static func *= (left: inout MCGeom.Vec2D, right: MCGeom.Vec2D) {
		left = left * right
	}
	
	public static func /= (left: inout MCGeom.Vec2D, right: MCGeom.Vec2D) {
		left = left / right
	}
}


// MARK: - Equality operator - 等価演算子

extension MCGeom.Vec2D {
	public static func == (left: MCGeom.Vec2D, right: MCGeom.Vec2D) -> Bool {
		return (left.x == right.x) && (left.y == right.y)
	}
	public static func != (left: MCGeom.Vec2D, right: MCGeom.Vec2D) -> Bool {
		return !(left == right)
	}
}


// MARK: - Utils

extension MCGeom.Vec2D {
	public func distance(point: MCGeom.Vec2D) -> Float {
		return MCGeom.Vec2D.distance(point1: self, point2: point)
	}
	
	public static func distance(point1: MCGeom.Vec2D, point2: MCGeom.Vec2D) -> Float {
		let xDist: Float = point2.x - point1.x
		let yDist: Float = point2.y - point1.y
		return sqrt((xDist * xDist) + (yDist * yDist))
	}
}


// MARK: - Convert

extension MCGeom.Vec2D {
	public func toCGPoint() -> CGPoint {
		return CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))
	}
	public func toCGSize() -> CGSize {
		return CGSize(width: CGFloat(self.x), height: CGFloat(self.y))
	}
}

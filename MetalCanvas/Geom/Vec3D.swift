//
//  MCGeom.Vec3D.swift
//  CameraCore
//
//  Created by hideyuki machida on 2018/12/25.
//  Copyright © 2018 町田 秀行. All rights reserved.
//

import Foundation

extension MCGeom {
	public struct Vec3D {
		public var x: Float = 0.0
		public var y: Float = 0.0
		public var z: Float = 0.0
		
		public init(x: Float = 0.0, y: Float = 0.0, z: Float = 0.0) {
			self.x = x
			self.y = y
			self.z = z
		}		
	}
}

// MARK: - initialize

public extension MCGeom.Vec3D {
	init() {
		self.x = 0.0
		self.y = 0.0
		self.z = 0.0
	}
	
	init(_ x: Float, _ y: Float, _ z: Float) {
		self.x = x
		self.y = y
		self.z = z
	}
}

// MARK: - CustomPlaygroundDisplayConvertible

extension MCGeom.Vec3D: CustomPlaygroundDisplayConvertible {
	public var playgroundDescription: Any {
		return (x: self.x, y: self.y, z: self.z)
	}
}


// MARK: - Basic operator - 演算子

public extension MCGeom.Vec3D {
	static func + (left: MCGeom.Vec3D, right: Float) -> MCGeom.Vec3D {
		return MCGeom.Vec3D(x: left.x + right, y: left.y + right, z: left.z + right)
	}
	
	static func - (left: MCGeom.Vec3D, right: Float) -> MCGeom.Vec3D {
		return MCGeom.Vec3D(x: left.x - right, y: left.y - right, z: left.z - right)
	}
	
	static func * (left: MCGeom.Vec3D, right: Float) -> MCGeom.Vec3D {
		return MCGeom.Vec3D(x: left.x * right, y: left.y * right, z: left.z * right)
	}
	
	static func / (left: MCGeom.Vec3D, right: Float) -> MCGeom.Vec3D {
		return MCGeom.Vec3D(x: left.x / right, y: left.y / right, z: left.z / right)
	}
}

public extension MCGeom.Vec3D {
	static func + (left: MCGeom.Vec3D, right: MCGeom.Vec3D) -> MCGeom.Vec3D {
		return MCGeom.Vec3D(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
	}
	
	static func - (left: MCGeom.Vec3D, right: MCGeom.Vec3D) -> MCGeom.Vec3D {
		return MCGeom.Vec3D(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
	}
	
	static func * (left: MCGeom.Vec3D, right: MCGeom.Vec3D) -> MCGeom.Vec3D {
		return MCGeom.Vec3D(x: left.x * right.x, y: left.y * right.y, z: left.z * right.z)
	}
	
	static func / (left: MCGeom.Vec3D, right: MCGeom.Vec3D) -> MCGeom.Vec3D {
		return MCGeom.Vec3D(x: left.x / right.x, y: left.y / right.y, z: left.z / right.z)
	}
}


// MARK: - Prefix operator - 前置演算子

public extension MCGeom.Vec3D {
	static prefix func + (left: MCGeom.Vec3D) -> MCGeom.Vec3D {
		return MCGeom.Vec3D(x: +left.x, y: +left.y, z: +left.z)
	}
	
	static prefix func - (left: MCGeom.Vec3D) -> MCGeom.Vec3D {
		return MCGeom.Vec3D(x: -left.x, y: -left.y, z: -left.z)
	}
}


// MARK: - Compound assignment operator - 複合代入演算子

public extension MCGeom.Vec3D {
	static func += (left: inout MCGeom.Vec3D, right: Float) {
		left = left + right
	}
	
	static func -= (left: inout MCGeom.Vec3D, right: Float) {
		left = left - right
	}
	
	static func *= (left: inout MCGeom.Vec3D, right: Float) {
		left = left * right
	}
	
	static func /= (left: inout MCGeom.Vec3D, right: Float) {
		left = left / right
	}
}

public extension MCGeom.Vec3D {
	static func += (left: inout MCGeom.Vec3D, right: MCGeom.Vec3D) {
		left = left + right
	}
	
	static func -= (left: inout MCGeom.Vec3D, right: MCGeom.Vec3D) {
		left = left - right
	}
	
	static func *= (left: inout MCGeom.Vec3D, right: MCGeom.Vec3D) {
		left = left * right
	}
	
	static func /= (left: inout MCGeom.Vec3D, right: MCGeom.Vec3D) {
		left = left / right
	}
}


// MARK: - Equality operator - 等価演算子

public extension MCGeom.Vec3D {
	static func == (left: MCGeom.Vec3D, right: MCGeom.Vec3D) -> Bool {
		return (left.x == right.x) && (left.y == right.y) && (left.z == right.z)
	}
	static func != (left: MCGeom.Vec3D, right: MCGeom.Vec3D) -> Bool {
		return !(left == right)
	}
}

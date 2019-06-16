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
	
	var color: [Float] = [1.0, 1.0, 1.0, 1.0]
	
	public init(r: Float, g: Float, b: Float, a: Float) {
		self.color = [r, g, b, a]
	}
	
	// MARK: - Hex
	
	public init(hex: String, alpha: Float = 1.0) {
		let hex: String = hex.replacingOccurrences(of: "#", with: "")
		let scanner: Scanner = Scanner(string: hex)
		scanner.scanLocation = 0
		var rgbValue: UInt64 = 0
		scanner.scanHexInt64(&rgbValue)
		let r: UInt64 = (rgbValue & 0xff0000) >> 16
		let g: UInt64 = (rgbValue & 0xff00) >> 8
		let b: UInt64 = rgbValue & 0xff
		
		self.color = [Float(r) / 0xff, Float(g) / 0xff, Float(b) / 0xff, alpha]
	}
	
	/*
	public var toHexString: String {
		//self.getRed(&r, green: &g, blue: &b, alpha: &a)
		
		return String(
			format: "%02X%02X%02X",
			Int(r * 0xff),
			Int(g * 0xff),
			Int(b * 0xff)
		)
	}
	*/
	
	// MARK: - RGB
	/*
	public init(r: Int = 0, g: Int = 0, b: Int = 0, a: Int = 255) {
		self.init( red: Float(max(min(r, 255), 0)) / 255, green: Float(max(min(g, 255), 0)) / 255, blue: Float(max(min(b, 255), 0)) / 255, alpha: Float(max(min(a, 255), 0)) / 255)
	}
	
	public convenience init(_ r: Int, _ g: Int, _ b: Int, _ a: Int) {
		self.init(r: r, g: g, b: b, a: a)
	}
	
	public convenience init(rgba: RGBA) {
		self.init(rgba.r, rgba.g, rgba.b, rgba.a)
	}
	
	public convenience init(rgb: RGB) {
		self.init(rgb.r, rgb.g, rgb.b, 255)
	}
	
	public var toRGBA: RGBA {
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		
		self.getRed(&r, green: &g, blue: &b, alpha: &a)
		
		return RGBA(r: Int(r * 255), g: Int(g * 255), b: Int(b * 255), a: Int(a * 255))
	}
	
	public var toRGB: RGB {
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		
		self.getRed(&r, green: &g, blue: &b, alpha: &a)
		
		return RGB(r: Int(r * 255), g: Int(g * 255), b: Int(b * 255))
	}

	public var toRGBAList: [Int] {
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		
		self.getRed(&r, green: &g, blue: &b, alpha: &a)
		
		return [Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255)]
	}
	*/
	
	// MARK: - HSV
	/*
	public convenience init(h: Int = 0, s: Int = 0, v: Int = 0, a: Int = 255) {
		self.init(hue: CGFloat(max(min(h, 255), 0)) / 255, saturation: CGFloat(max(min(s, 255), 0)) / 255, brightness: CGFloat(max(min(v, 255), 0)) / 255, alpha: CGFloat(max(min(a, 255), 0)) / 255)
	}
	
	public convenience init(hsva: HSVA) {
		self.init(h: hsva.h, s: hsva.s, v: hsva.v, a: hsva.a)
	}
	
	public convenience init(hsv: HSV) {
		self.init(h: hsv.h, s: hsv.s, v: hsv.v, a: 255)
	}
	
	public var toHSVA: HSVA {
		var h: CGFloat = 0
		var s: CGFloat = 0
		var v: CGFloat = 0
		var a: CGFloat = 0
		
		self.getHue(&h, saturation: &s, brightness: &v, alpha: &a)
		
		return HSVA(h: Int(h * 255), s: Int(s * 255), v: Int(v * 255), a: Int(a * 255))
	}

	public var toHSV: HSV {
		var h: CGFloat = 0
		var s: CGFloat = 0
		var v: CGFloat = 0
		var a: CGFloat = 0
		
		self.getHue(&h, saturation: &s, brightness: &v, alpha: &a)
		
		return HSV(h: Int(h * 255), s: Int(s * 255), v: Int(v * 255))
	}
	*/
}

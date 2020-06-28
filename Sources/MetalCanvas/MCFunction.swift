//
//  MCFunction.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/02.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation
import Metal

public enum MCFunction {
	public enum ColorSpace {
		case YCbCrToRGB
		
		public var kernel: MTLFunction {
			switch self {
			case .YCbCrToRGB: return MCCore.library.makeFunction(name: "kernel_YCbCrToRGB")!
			}
		}
		public var vertex: MTLFunction {
			switch self {
			case .YCbCrToRGB: return MCCore.library.makeFunction(name: "vertex_YCbCrToRGB")!
			}
		}
		
		public var fragment: MTLFunction {
			switch self {
			case .YCbCrToRGB: return MCCore.library.makeFunction(name: "fragment_YCbCrToRGB")!
			}
		}

	}

	public enum Primitive {
		case point
		case points
		case image
		case triangle
		
		public var vertex: MTLFunction {
			switch self {
			case .point: return MCCore.library.makeFunction(name: "vertex_primitive_point")!
			case .points: return MCCore.library.makeFunction(name: "vertex_primitive_points")!
			case .image: return MCCore.library.makeFunction(name: "vertex_primitive_image")!
			case .triangle: return MCCore.library.makeFunction(name: "vertex_primitive_triangle")!
			}
		}
		
		public var fragment: MTLFunction {
			switch self {
			case .point: return MCCore.library.makeFunction(name: "fragment_primitive_point")!
			case .points: return MCCore.library.makeFunction(name: "fragment_primitive_points")!
			case .image: return MCCore.library.makeFunction(name: "fragment_primitive_image")!
			case .triangle: return MCCore.library.makeFunction(name: "fragment_primitive_triangle")!
			}
		}
	}
	
	public enum ImageBlending {
		case alphaBlending
		case depthBlending
		
		public var kernel: MTLFunction {
			switch self {
			case .alphaBlending: return MCCore.library.makeFunction(name: "kernel_imageBlending_alphaBlending")!
			case .depthBlending: return MCCore.library.makeFunction(name: "kernel_imageBlending_depthBlending")!
			}
		}
	}
	
	public enum ColorProcessing {
		case lut1D
		case lut3D
		
		public var vertex: MTLFunction {
			switch self {
			case .lut1D: return MCCore.library.makeFunction(name: "vertex_Lut1DFilter")!
			case .lut3D: return MCCore.library.makeFunction(name: "vertex_Lut3DFilter")!
			}
		}
		
		public var fragment: MTLFunction {
			switch self {
			case .lut1D: return MCCore.library.makeFunction(name: "fragment_Lut1DFilter")!
			case .lut3D: return MCCore.library.makeFunction(name: "fragment_Lut3DFilter")!
			}
		}
	}
}

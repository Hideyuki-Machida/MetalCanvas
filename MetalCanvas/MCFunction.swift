//
//  MCFunction.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/02.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation


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
            case .point: return Functions.vertex_primitive_point
            case .points: return Functions.vertex_primitive_points
            case .image: return Functions.vertex_primitive_image
            case .triangle: return Functions.vertex_primitive_triangle
            }
        }
        
        public var fragment: MTLFunction {
            switch self {
            case .point: return Functions.fragment_primitive_point
            case .points: return Functions.fragment_primitive_points
            case .image: return Functions.fragment_primitive_image
            case .triangle: return Functions.fragment_primitive_triangle
            }
        }
    }
    
    public enum ImageBlending {
        case alphaBlending
        case depthBlending
        
        public var kernel: MTLFunction {
            switch self {
            case .alphaBlending: return Functions.kernel_imageBlending_alphaBlending
            case .depthBlending: return Functions.kernel_imageBlending_depthBlending
            }
        }
    }
    
    public enum ColorProcessing {
        case lut3D
        
        public var vertex: MTLFunction {
            switch self {
            case .lut3D: return Functions.vertex_Lut3DFilter
            }
        }
        
        public var fragment: MTLFunction {
            switch self {
            case .lut3D: return Functions.fragment_Lut3DFilter
            }
        }
    }
    
    struct Functions {
        static let vertex_primitive_point: MTLFunction = MCCore.library.makeFunction(name: "vertex_primitive_point")!
        static let vertex_primitive_points: MTLFunction = MCCore.library.makeFunction(name: "vertex_primitive_points")!
        static let vertex_primitive_image: MTLFunction = MCCore.library.makeFunction(name: "vertex_primitive_image")!
        static let vertex_primitive_triangle: MTLFunction = MCCore.library.makeFunction(name: "vertex_primitive_triangle")!

        static let fragment_primitive_point: MTLFunction = MCCore.library.makeFunction(name: "fragment_primitive_point")!
        static let fragment_primitive_points: MTLFunction = MCCore.library.makeFunction(name: "fragment_primitive_points")!
        static let fragment_primitive_image: MTLFunction = MCCore.library.makeFunction(name: "fragment_primitive_image")!
        static let fragment_primitive_triangle: MTLFunction = MCCore.library.makeFunction(name: "fragment_primitive_triangle")!

        static let kernel_imageBlending_alphaBlending: MTLFunction = MCCore.library.makeFunction(name: "kernel_imageBlending_alphaBlending")!
        static let kernel_imageBlending_depthBlending: MTLFunction = MCCore.library.makeFunction(name: "kernel_imageBlending_depthBlending")!

        static let vertex_Lut3DFilter: MTLFunction = MCCore.library.makeFunction(name: "vertex_Lut3DFilter")!
        static let fragment_Lut3DFilter: MTLFunction = MCCore.library.makeFunction(name: "fragment_Lut3DFilter")!
    }
}

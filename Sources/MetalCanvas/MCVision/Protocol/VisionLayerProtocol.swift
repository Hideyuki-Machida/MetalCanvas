//
//  VisionLayerProtocol.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2020/01/07.
//  Copyright © 2020 hideyuki machida. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////////////////////////////////

// MARK: - ImageRecognitionLayerErrorType

public enum VisionLayerErrorType: Error {
    case decodeError
    case setupError
    case renderingError
}

///////////////////////////////////////////////////////////////////////////////////////////////////

public protocol VisionLayerProtocol {
    mutating func process(sorce: MCTexture, resul: inout [String : VisionResultProtocol], queue: DispatchQueue) throws
}

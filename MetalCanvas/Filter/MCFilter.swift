//
//  MCFilter.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/03.
//  Copyright © 2019 Donuts. All rights reserved.
//

import Foundation

public struct MCFilter {
    private init() {} // このstructはnamespace用途なのでインスタンス化防止

    public enum ErrorType: Error {
        case setupError
        case drawError
        case endError
    }
}

public protocol MCFilterProtocol {}
